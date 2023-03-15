using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using VippsAgreement = SkredvarselGarminWeb.VippsApi.Models.Agreement;
using VippsCampaignType = SkredvarselGarminWeb.VippsApi.Models.CampaignType;
using EntityAgreement = SkredvarselGarminWeb.Entities.Agreement;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Services;

public class SubscriptionService : ISubscriptionService
{
    private const string ChargeText = "Abonnement på Skredvarsel for Garmin";

    private readonly SkredvarselDbContext _dbContext;
    private readonly IVippsApiClient _vippsApiClient;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;
    private readonly ILogger<SubscriptionService> _logger;

    public SubscriptionService(
        SkredvarselDbContext dbContext,
        IVippsApiClient vippsApiClient,
        IDateTimeNowProvider dateTimeNowProvider,
        ILogger<SubscriptionService> logger)
    {
        _dbContext = dbContext;
        _vippsApiClient = vippsApiClient;
        _dateTimeNowProvider = dateTimeNowProvider;
        _logger = logger;
    }

    public async Task UpdateAgreementCharges(string agreementId)
    {
        var agreement = _dbContext.Agreements
            .Where(a => a.Id == agreementId)
            .First();

        var nowDate = DateOnly.FromDateTime(_dateTimeNowProvider.Now);
        if (nowDate < agreement.NextChargeDate)
        {
            // Not due for a charge
            _logger.LogWarning("Job was triggered to update charges on an agreement that is not due for a charge.");
            return;
        }

        _logger.LogInformation("Updating charges for agreement {agreementId}", agreement.Id);

        var vippsAgreement = await _vippsApiClient.GetAgreement(agreement.Id);

        if (vippsAgreement.Status == VippsAgreementStatus.Active)
        {
            if (agreement.NextChargeId == null)
            {
                _logger.LogInformation("Agreement did not have a NextChargeId set, creating new charge.");
                await CreateAndStoreNewCharge(agreement, vippsAgreement);
            }
            else
            {
                var nextCharge = await _vippsApiClient.GetCharge(agreement.Id, agreement.NextChargeId);

                if (nextCharge.Status == ChargeStatus.CHARGED)
                {
                    _logger.LogWarning("Due charge for agreement was already charged. This should not happen.");
                    await CreateAndStoreNewCharge(agreement, vippsAgreement);
                }
                else if (nextCharge.Status == ChargeStatus.RESERVED)
                {
                    _logger.LogInformation("Capturing charge {chargeId} for agreement {agreementId} and creating new charge.", nextCharge.Id, agreement.Id);
                    var response = await _vippsApiClient.CaptureCharge(agreement.Id, nextCharge.Id, new CaptureChargeRequest
                    {
                        Amount = nextCharge.Amount,
                        Description = ChargeText
                    }, Guid.NewGuid());

                    if (response.IsSuccessStatusCode)
                    {
                        await CreateAndStoreNewCharge(agreement, vippsAgreement);
                    }
                    else
                    {
                        _logger.LogError(response.Error, response.Error?.Content);
                        throw new Exception($"Failed to capture charge {nextCharge.Id}.");
                    }
                }
                else
                {
                    _logger.LogWarning("Due charge for agreement was not charged and not reserved. Status was {status}. Will retry, possibly forever.", nextCharge.Status);
                }
            }
        }
    }

    private async Task CreateAndStoreNewCharge(EntityAgreement agreement, VippsAgreement vippsAgreement)
    {
        var (nextChargeDate, nextChargeAmount) = CalculateNextCharge(vippsAgreement);
        var newCharge = await _vippsApiClient.CreateCharge(agreement.Id, new CreateChargeRequest
        {
            Amount = nextChargeAmount,
            Description = ChargeText,
            Due = nextChargeDate,
            RetryDays = 2,
        }, Guid.NewGuid());

        agreement.NextChargeDate = nextChargeDate;
        agreement.NextChargeId = newCharge.ChargeId;

        _dbContext.SaveChanges();
    }

    private (DateOnly, int) CalculateNextCharge(VippsAgreement vippsAgreement)
    {
        var now = _dateTimeNowProvider.Now;
        var nowDateOnly = DateOnly.FromDateTime(now);

        _logger.LogInformation("Calculating next charge for agreement {agreementId}", vippsAgreement.Id);

        if (vippsAgreement.Campaign != null)
        {
            var campaign = vippsAgreement.Campaign;

            if (campaign.Type == VippsCampaignType.PeriodCampaign)
            {
                var periodEndDate = GetNextChargeDate(DateOnly.FromDateTime(vippsAgreement.Start!.Value), campaign.Period!.Unit, campaign.Period!.Count);

                if (nowDateOnly < periodEndDate)
                {
                    // Active period campaign. Next charge should be full price at the end of the campaign.
                    var charge = (periodEndDate, vippsAgreement.Pricing.Amount);

                    _logger.LogInformation("Agreement is in an active period campaign. Next charge date is {nextChargeDate} with price {price}", charge.periodEndDate, charge.Amount);
                    return charge;
                }
            }
            else if (campaign.Type == VippsCampaignType.PriceCampaign && now < campaign.End)
            {
                // Active price campaign, next charge should be campaign price at campaign interval.
                var charge = (
                    GetNextChargeDate(nowDateOnly, vippsAgreement.Interval.Unit, vippsAgreement.Interval.Count),
                    campaign.Price
                );

                _logger.LogInformation("Agreement is in an active price campaign. Next charge date is {nextChargeDate} with price {price}", charge.Item1, charge.Price);

                return charge;
            }
            else if (campaign.Type == VippsCampaignType.EventCampaign || campaign.Type == VippsCampaignType.FullFlexCampaign)
            {
                throw new Exception("Unsupported campaign type");
            }
        }

        var nextChargeDate = GetNextChargeDate(nowDateOnly, vippsAgreement.Interval.Unit, vippsAgreement.Interval.Count);
        var nextCharge = (nextChargeDate, vippsAgreement.Pricing.Amount);

        _logger.LogInformation("Agreement is outside campaign. Next charge date is {nextChargeDate} with price {price}", nextCharge.nextChargeDate, nextCharge.Amount);

        return (nextChargeDate, vippsAgreement.Pricing.Amount);
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
