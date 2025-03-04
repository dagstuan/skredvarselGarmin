using Hangfire;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

using EntityAgreement = SkredvarselGarminWeb.Entities.Agreement;
using EntityAgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using VippsAgreement = SkredvarselGarminWeb.VippsApi.Models.Agreement;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using VippsCampaignType = SkredvarselGarminWeb.VippsApi.Models.CampaignType;

namespace SkredvarselGarminWeb.Services;

public class VippsAgreementService(
    SkredvarselDbContext dbContext,
    IVippsApiClient vippsApiClient,
    IDateTimeNowProvider dateTimeNowProvider,
    INotificationService notificationService,
    ILogger<VippsAgreementService> logger) : IVippsAgreementService
{
    private readonly TimeSpan ChargeRetryDays = TimeSpan.FromDays(6);
    private const string ChargeText = "Abonnement på Skredvarsel for Garmin";

    public async Task CreateNextChargeForAgreement(string agreementId)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        var agreement = dbContext.Agreements
            .Single(a => a.Id == agreementId);

        if (agreement.Status != EntityAgreementStatus.ACTIVE)
        {
            logger.LogWarning("Job to create agreement charge for agreement was triggered agreement that was not active. Agreement ID: {agreementId}", agreementId);
            return;
        }

        if (agreement.NextChargeId != null)
        {
            logger.LogWarning("Job to create agreement charge for agreement was triggered on agreement that already has a next charge. Agreement ID: {agreementId}", agreementId);
            return;
        }

        if (!agreement.NextChargeDate.HasValue)
        {
            logger.LogError("Failed to create charge for agreement. Next charge date was not set. This should never happen.");
            throw new Exception("Failed to create charge for agreement. Next charge date was not set. This should never happen.");
        }

        if (agreement.NextChargeAmount == null)
        {
            logger.LogError("Failed to create charge for agreement. Next charge amount was not set. This should never happen.");
            throw new Exception("Failed to create charge for agreement. Next charge amount was not set. This should never happen.");
        }

        var dueInDays = (agreement.NextChargeDate.Value.ToDateTime(TimeOnly.MinValue) - dateTimeNowProvider.Now).TotalDays;
        if (dueInDays > 31)
        {
            // Not due for a charge
            logger.LogWarning("Job was triggered to create charge on an agreement that is not due for a charge within 30 days. Agreement ID: {agreementId}. Agreement is due in {dueInDays} days.", agreementId, dueInDays);
            return;
        }

        var vippsAgreement = await vippsApiClient.GetAgreement(agreement.Id);

        if (vippsAgreement.Status == VippsAgreementStatus.Active)
        {
            logger.LogInformation("Agreement {agreementId} due for charge in {days} days. Creating charge.", agreement.Id, dueInDays);

            var newCharge = await CreateChargeInVipps(agreement.Id, agreement.NextChargeDate.Value, agreement.NextChargeAmount.Value);

            agreement.NextChargeId = newCharge.ChargeId;
            dbContext.SaveChanges();
        }
        else if (vippsAgreement.Status == VippsAgreementStatus.Stopped)
        {
            logger.LogInformation("Agreement {agreementId} was stopped in Vipps when creating next charge. Setting as unsubscribed.", agreement.Id);
            agreement.SetAsUnsubscribed();
            dbContext.SaveChanges();

            _ = Task.Run(notificationService.NotifyUserDeactivated);
        }

        transaction.Commit();
    }

    [DisableConcurrentExecution(10)]
    public async Task UpdateAgreementCharges(string agreementId)
    {
        var isExistingTransaction = dbContext.Database.CurrentTransaction != null;

        if (!isExistingTransaction)
        {
            using var transaction = dbContext.Database.BeginTransaction();

            await UpdateAgreementChargesInternal(agreementId);

            transaction.Commit();
        }
        else
        {
            await UpdateAgreementChargesInternal(agreementId);
        }
    }

    private async Task UpdateAgreementChargesInternal(string agreementId)
    {
        var agreement = dbContext.Agreements.SingleOrDefault(a => a.Id == agreementId);

        if (agreement == null)
        {
            logger.LogWarning("Job to update agreement charges for agreement was triggered on non-existing agreement. Agreement ID: {agreementId}", agreementId);
            return;
        }

        if (agreement.Status != EntityAgreementStatus.ACTIVE &&
            agreement.Status != EntityAgreementStatus.UNSUBSCRIBED)
        {
            logger.LogWarning("Job to update agreement charges for agreement was triggered on inactive agreement. Agreement ID: {agreementId}", agreementId);
            throw new Exception("Job to update agreement charges for agreement was triggered on inactive agreement.");
        }

        if (!agreement.NextChargeDate.HasValue)
        {
            logger.LogWarning("Job to update agreement charges for agreement was triggered on agreement that did not have next charge date set. Agreement ID: {agreementId}", agreementId);
            throw new Exception("Job to update agreement charges for agreement was triggered on agreement that did not have next charge date set.");
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
            logger.LogInformation("Agreement {agreementId} was unsubscribed and due for charge. Stopping agreement.", agreement.Id);
            await StopAgreement(agreement, vippsAgreement);
            return;
        }

        logger.LogInformation("Updating charges for agreement {agreementId}", agreement.Id);

        if (vippsAgreement.Status == VippsAgreementStatus.Active)
        {
            if (agreement.NextChargeId == null)
            {
                logger.LogInformation("Agreement did not have a NextChargeId set. Charge should be created by separate job. This should not happen.");
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
                    if (numChargesInVipps > 1)
                    {
                        logger.LogError("Multiple new charges found in Vipps. This should not happen.");
                        throw new Exception("Multiple new charges found in Vipps. This should not happen.");
                    }
                    else
                    {
                        logger.LogInformation("No new charge found in Vipps. Updating charge status. This should not happen.");

                        var (nextChargeDate, nextChargeAmount) = CalculateNextCharge(vippsAgreement, agreement.NextChargeDate.Value);
                        agreement.NextChargeDate = nextChargeDate;
                        agreement.NextChargeAmount = nextChargeAmount;
                        agreement.NextChargeId = null;
                        dbContext.SaveChanges();
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
                        var (nextChargeDate, nextChargeAmount) = CalculateNextCharge(vippsAgreement, agreement.NextChargeDate.Value);

                        agreement.NextChargeDate = nextChargeDate;
                        agreement.NextChargeAmount = nextChargeAmount;
                        agreement.NextChargeId = null;
                        dbContext.SaveChanges();
                    }
                    else
                    {
                        _ = Task.Run(notificationService.NotifyChargeFailed);

                        logger.LogError(response.Error, "Failed to capture charge. Response content: {responseContent}", response.Error?.Content);
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
                    // If next charge is due, and time passed is less than retrydays, do nothing since Hangfire will retry.
                    logger.LogWarning("Next charge for agreement {agreementId} had unknown status. Status was {status}. Will retry.", agreement.Id, nextCharge.Status);
                }
            }
        }
        else if (vippsAgreement.Status == VippsAgreementStatus.Stopped)
        {
            logger.LogInformation("Agreement {agreementId} was stopped in Vipps. Setting as stopped.", agreement.Id);
            agreement.SetAsStopped();
            dbContext.SaveChanges();
        }
        else
        {
            logger.LogWarning("Agreement {agreementId} was not active in Vipps. Status was {status}.", agreement.Id, vippsAgreement.Status);
        }
    }

    public async Task StopAgreement(string agreementId)
    {
        var agreement = dbContext.Agreements.First(a => a.Id == agreementId);

        var vippsAgreement = await vippsApiClient.GetAgreement(agreementId);

        await StopAgreement(agreement, vippsAgreement);
    }

    private async Task StopAgreement(EntityAgreement agreement, VippsAgreement vippsAgreement)
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

        agreementInDb.SetAsUnsubscribed();
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

        if (!agreementInDb.NextChargeAmount.HasValue || !agreementInDb.NextChargeDate.HasValue)
        {
            throw new Exception("Can't reactivate agreement since next charge amount or date is not set.");
        }

        var vippsAgreement = await vippsApiClient.GetAgreement(agreementId);

        var (nextChargeDate, nextChargeAmount) = CalculateNextCharge(vippsAgreement, agreementInDb.NextChargeDate.Value);

        agreementInDb.NextChargeDate = nextChargeDate;
        agreementInDb.NextChargeAmount = nextChargeAmount;

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

            if (campaign.Type is VippsCampaignType.PeriodCampaign)
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
            else if (campaign.Type is VippsCampaignType.PriceCampaign && now < campaign.End)
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
            else if (campaign.Type is VippsCampaignType.EventCampaign or VippsCampaignType.FullFlexCampaign)
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
