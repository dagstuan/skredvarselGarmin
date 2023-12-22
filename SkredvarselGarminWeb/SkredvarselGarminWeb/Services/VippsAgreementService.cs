using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using VippsAgreement = SkredvarselGarminWeb.VippsApi.Models.Agreement;
using VippsCampaignType = SkredvarselGarminWeb.VippsApi.Models.CampaignType;
using EntityAgreement = SkredvarselGarminWeb.Entities.Agreement;
using EntityAgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Entities.Extensions;
using Hangfire;

namespace SkredvarselGarminWeb.Services;

public class VippsAgreementService(
    SkredvarselDbContext dbContext,
    IVippsApiClient vippsApiClient,
    IDateTimeNowProvider dateTimeNowProvider,
    ILogger<VippsAgreementService> logger) : IVippsAgreementService
{
    private readonly TimeSpan ChargeRetryDays = TimeSpan.FromDays(3);
    private const string ChargeText = "Abonnement på Skredvarsel for Garmin";

    [DisableConcurrentExecution(10)]
    public async Task UpdateAgreementCharges(string agreementId)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        await UpdateAgreementChargesInternal(agreementId);

        transaction.Commit();
    }

    private async Task UpdateAgreementChargesInternal(string agreementId)
    {
        var agreement = dbContext.Agreements
            .Where(a => a.Id == agreementId)
            .Where(a =>
                a.Status == EntityAgreementStatus.ACTIVE ||
                a.Status == EntityAgreementStatus.UNSUBSCRIBED)
            .FirstOrDefault();

        if (agreement == null)
        {
            logger.LogWarning("Job to update agreement charges for agreement was triggered on inactive agreement. Agreement ID: {agreementId}", agreementId);
            return;
        }

        var nowDate = DateOnly.FromDateTime(dateTimeNowProvider.Now);
        if (nowDate < agreement.NextChargeDate)
        {
            // Not due for a charge
            logger.LogWarning("Job was triggered to update charges on an agreement that is not due for a charge. Agreement ID: {agreementId}", agreementId);
            return;
        }

        var vippsAgreement = await vippsApiClient.GetAgreement(agreement.Id);

        if (agreement.Status == EntityAgreementStatus.UNSUBSCRIBED && nowDate >= agreement.NextChargeDate)
        {
            logger.LogInformation("Agreement {agreementId} was unsubscribed and due for charge.", agreement.Id);

            await StopAgreement(agreement, vippsAgreement);
        }
        else
        {
            logger.LogInformation("Updating charges for agreement {agreementId}", agreement.Id);

            if (vippsAgreement.Status == VippsAgreementStatus.Active)
            {
                if (agreement.NextChargeId == null || !agreement.NextChargeDate.HasValue)
                {
                    logger.LogInformation("Agreement did not have a NextChargeId set, creating new charge. Assuming previous charge was today. This should not happen.");
                    await CreateAndStoreNewChargeForAgreement(agreement, vippsAgreement, DateOnly.FromDateTime(dateTimeNowProvider.Now));
                }
                else
                {
                    var nextCharge = await vippsApiClient.GetCharge(agreement.Id, agreement.NextChargeId);

                    if (nextCharge.Status == ChargeStatus.CHARGED)
                    {
                        logger.LogWarning("Due charge for agreement was already charged. This should not happen.");

                        // Check for existing charge in Vipps.
                        var pendingChargesInVipps = vippsApiClient.GetCharges(agreement.Id, ChargeStatus.PENDING);
                        var dueChargesInVipps = vippsApiClient.GetCharges(agreement.Id, ChargeStatus.DUE);
                        var reservedChargesInVipps = vippsApiClient.GetCharges(agreement.Id, ChargeStatus.RESERVED);

                        await Task.WhenAll(pendingChargesInVipps, dueChargesInVipps, reservedChargesInVipps);

                        var chargesInVipps = (await pendingChargesInVipps)
                            .Concat(await dueChargesInVipps)
                            .Concat(await reservedChargesInVipps);

                        var numChargesInVipps = chargesInVipps.Count();
                        if (numChargesInVipps == 1)
                        {
                            var chargeInVipps = chargesInVipps.Single();
                            logger.LogInformation("Found pending or due charge in Vipps, setting it as next charge.");

                            agreement.NextChargeDate = DateOnly.FromDateTime(chargeInVipps.Due);
                            agreement.NextChargeId = nextCharge.Id;
                        }
                        else if (numChargesInVipps > 1)
                        {
                            logger.LogError("Multiple new charges found in Vipps. This should not happen.");
                            throw new Exception("Multiple new charges found in Vipps. This should not happen.");
                        }
                        else
                        {
                            logger.LogInformation("No new charge found in Vipps. Creating new charge.");
                            await CreateAndStoreNewChargeForAgreement(agreement, vippsAgreement, agreement.NextChargeDate.Value);
                        }
                    }
                    else if (nextCharge.Status == ChargeStatus.DUE)
                    {
                        logger.LogWarning("Next charge for agreement {agreementId} was still due. Charge id {chargeId}. Will retry.", agreement.Id, nextCharge.Id);
                    }
                    else if (nextCharge.Status == ChargeStatus.RESERVED)
                    {
                        logger.LogInformation("Capturing charge {chargeId} for agreement {agreementId} and creating new charge.", nextCharge.Id, agreement.Id);
                        var response = await vippsApiClient.CaptureCharge(agreement.Id, nextCharge.Id, new CaptureChargeRequest
                        {
                            Amount = nextCharge.Amount,
                            Description = ChargeText
                        }, Guid.NewGuid());

                        if (response.IsSuccessStatusCode)
                        {
                            await CreateAndStoreNewChargeForAgreement(agreement, vippsAgreement, agreement.NextChargeDate.Value);
                        }
                        else
                        {
                            logger.LogError(response.Error, response.Error?.Content);
                            throw new Exception($"Failed to capture charge {nextCharge.Id}.");
                        }
                    }
                    else if (nextCharge.Status == ChargeStatus.FAILED)
                    {
                        logger.LogInformation("Agreement {agreementId} had nextCharge status failed. Stopping agreement. Failed charge had id {chargeId}", agreement.Id, nextCharge.Id);

                        await StopAgreement(agreement, vippsAgreement);
                    }
                    else
                    {
                        // If nextcharge is due, and time passed is less than retrydays, do nothing since HF will retry.
                        logger.LogWarning("Next charge for agreement {agreementId} had unknown status. Status was {status}. Will retry.", agreement.Id, nextCharge.Status);
                    }
                }
            }
        }
    }

    public async Task StopAgreement(EntityAgreement agreement, VippsAgreement vippsAgreement)
    {
        logger.LogInformation("Stopping agreement in vipps and setting as stopped.");

        if (vippsAgreement.Status != VippsAgreementStatus.Stopped)
        {
            var success = await StopAgreementInVipps(agreement.Id);

            if (!success)
            {
                logger.LogError("Failed to stop agreement in Vipps.");
                throw new Exception("Failed to stop agreement in Vipps.");
            }
        }

        agreement.SetAsStopped();
        dbContext.SaveChanges();
    }

    public async Task DeactivateAgreement(string agreementId)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        logger.LogInformation("Deactivating agreement {agreementId}", agreementId);

        var agreementInDb = dbContext.Agreements.First(a => a.Id == agreementId);

        if (agreementInDb.Status != EntityAgreementStatus.ACTIVE)
        {
            throw new Exception("Invalid state for agreement attempting to be deactivated.");
        }

        // If the agreement is new, claim the first charge before deactivating.
        await UpdateAgreementChargesInternal(agreementId);

        if (agreementInDb.NextChargeId != null)
        {
            var result = await vippsApiClient.CancelCharge(agreementInDb.Id, agreementInDb.NextChargeId, Guid.NewGuid());

            if (result.IsSuccessStatusCode)
            {
                agreementInDb.NextChargeId = null;
            }
            else
            {
                logger.LogWarning("Failed to cancel charge when unsubscribing.");
            }
        }

        agreementInDb.Status = EntityAgreementStatus.UNSUBSCRIBED;
        dbContext.SaveChanges();

        transaction.Commit();
    }

    public async Task ReactivateAgreement(string agreementId)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        logger.LogInformation("Reactivating agreement {agreementId}", agreementId);

        var agreementInDb = dbContext.Agreements.First(a => a.Id == agreementId);

        if (agreementInDb.Status != EntityAgreementStatus.UNSUBSCRIBED || !agreementInDb.NextChargeDate.HasValue)
        {
            throw new Exception("Invalid state for agreement attempting to be reactivated.");
        }

        var vippsAgreement = await vippsApiClient.GetAgreement(agreementId);

        var (nextChargeDate, amount) = CalculateNextCharge(vippsAgreement, agreementInDb.NextChargeDate.Value);

        var charge = await CreateChargeInVipps(agreementId, nextChargeDate, amount);

        agreementInDb.NextChargeId = charge.ChargeId;
        agreementInDb.SetAsActive();
        dbContext.SaveChanges();

        transaction.Commit();
    }

    private async Task<bool> StopAgreementInVipps(string agreementId)
    {
        logger.LogInformation("Stopping agreement {agreementId} in Vipps", agreementId);

        var result = await vippsApiClient.PatchAgreement(agreementId, new PatchAgreementRequest
        {
            Status = PatchAgreementStatus.Stopped
        }, Guid.NewGuid());

        if (!result.IsSuccessStatusCode)
        {
            logger.LogWarning("Failed to stop agreement in Vipps. Will be retried by Hangfire.");
            return false;
        }

        return true;
    }

    private async Task CreateAndStoreNewChargeForAgreement(EntityAgreement agreement, VippsAgreement vippsAgreement, DateOnly previousChargeDate)
    {
        var (nextChargeDate, nextChargeAmount) = CalculateNextCharge(vippsAgreement, previousChargeDate);
        var newCharge = await CreateChargeInVipps(agreement.Id, nextChargeDate, nextChargeAmount);

        agreement.NextChargeDate = nextChargeDate;
        agreement.NextChargeId = newCharge.ChargeId;

        dbContext.SaveChanges();
    }

    private async Task<CreateChargeResponse> CreateChargeInVipps(string agreementId, DateOnly due, int amount)
    {
        return await vippsApiClient.CreateCharge(agreementId, new CreateChargeRequest
        {
            Amount = amount,
            Description = ChargeText,
            Due = due,
            RetryDays = ChargeRetryDays.Days,
        }, Guid.NewGuid());
    }

    private (DateOnly, int) CalculateNextCharge(VippsAgreement vippsAgreement, DateOnly previousChargeDate)
    {
        var now = dateTimeNowProvider.Now;
        var nowDateOnly = DateOnly.FromDateTime(now);

        logger.LogInformation("Calculating next charge for agreement {agreementId}", vippsAgreement.Id);

        if (vippsAgreement.Campaign != null)
        {
            var campaign = vippsAgreement.Campaign;

            if (campaign.Type == VippsCampaignType.PeriodCampaign)
            {
                var periodEndDate = GetNextChargeDate(DateOnly.FromDateTime(vippsAgreement.Start!.Value), campaign.Period!.Unit, campaign.Period!.Count);

                if (nowDateOnly < periodEndDate)
                {
                    // Active period campaign. Next charge should be full price at the end of the campaign.
                    var charge = (
                        periodEndDate,
                        vippsAgreement.Pricing.Amount
                    );

                    logger.LogInformation("Agreement is in an active period campaign. Next charge date is {nextChargeDate} with price {price}", charge.periodEndDate, charge.Amount);
                    return charge;
                }
            }
            else if (campaign.Type == VippsCampaignType.PriceCampaign && now < campaign.End)
            {
                var nextChargeDate = DateOnly.FromDateTime(now) < previousChargeDate ? previousChargeDate : GetNextChargeDate(previousChargeDate, vippsAgreement.Interval.Unit, vippsAgreement.Interval.Count);

                // Active price campaign, next charge should be campaign price at campaign interval.
                var charge = (
                    nextChargeDate,
                    campaign.Price
                );

                logger.LogInformation("Agreement is in an active price campaign. Next charge date is {nextChargeDate} with price {price}", charge.nextChargeDate, charge.Price);

                return charge;
            }
            else if (campaign.Type == VippsCampaignType.EventCampaign || campaign.Type == VippsCampaignType.FullFlexCampaign)
            {
                throw new Exception("Unsupported campaign type");
            }
        }

        if (nowDateOnly < previousChargeDate)
        {
            // Should create charge at previous charge date;
            var nextChargeDate = previousChargeDate;
            var nextCharge = (nextChargeDate, vippsAgreement.Pricing.Amount);
            logger.LogInformation("Agreement is outside campaign but nextChargeDate has not happened yet. Next charge date is {nextChargeDate} with price {price}", nextCharge.nextChargeDate, nextCharge.Amount);

            return nextCharge;
        }
        else
        {
            var nextChargeDate = GetNextChargeDate(previousChargeDate, vippsAgreement.Interval.Unit, vippsAgreement.Interval.Count);
            var nextCharge = (nextChargeDate, vippsAgreement.Pricing.Amount);
            logger.LogInformation("Agreement is outside campaign. Next charge date is {nextChargeDate} with price {price}", nextCharge.nextChargeDate, nextCharge.Amount);
            return nextCharge;
        }
    }

    private static DateOnly GetNextChargeDate(DateOnly previousChargeDate, PeriodUnit unit, int count) => unit switch
    {
        PeriodUnit.Day => previousChargeDate.AddDays(count),
        PeriodUnit.Month => previousChargeDate.AddMonths(count),
        PeriodUnit.Year => previousChargeDate.AddYears(count),
        PeriodUnit.Week => previousChargeDate.AddDays(count * 7),
        _ => throw new NotImplementedException(),
    };
}