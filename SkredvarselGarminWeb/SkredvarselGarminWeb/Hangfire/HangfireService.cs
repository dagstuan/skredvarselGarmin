using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.Entities.Mappers;
using SkredvarselGarminWeb.VippsApi.Models;
using Hangfire;

using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using VippsAgreement = SkredvarselGarminWeb.VippsApi.Models.Agreement;
using VippsCampaignType = SkredvarselGarminWeb.VippsApi.Models.CampaignType;
using EntityAgreement = SkredvarselGarminWeb.Entities.Agreement;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Hangfire;

public class HangfireService
{
    private const string ChargeText = "Abonnement på Skredvarsel for Garmin";

    private readonly SkredvarselDbContext _dbContext;
    private readonly IVippsApiClient _vippsApiClient;
    private readonly IBackgroundJobClient _backgroundJobClient;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;
    private readonly ILogger<HangfireService> _logger;

    public HangfireService(
        SkredvarselDbContext dbContext,
        IVippsApiClient vippsApiClient,
        IBackgroundJobClient backgroundJobClient,
        IDateTimeNowProvider dateTimeNowProvider,
        ILogger<HangfireService> logger)
    {
        _dbContext = dbContext;
        _vippsApiClient = vippsApiClient;
        _backgroundJobClient = backgroundJobClient;
        _dateTimeNowProvider = dateTimeNowProvider;
        _logger = logger;
    }

    public async Task UpdateAgreements()
    {
        var agreementsInDb = _dbContext.Agreements.ToList();

        foreach (var agreement in agreementsInDb)
        {
            var agreementInVipps = await _vippsApiClient.GetAgreement(agreement.Id);

            if (agreementInVipps.Status == VippsAgreementStatus.Stopped || agreementInVipps.Status == VippsAgreementStatus.Expired)
            {
                _dbContext.Remove(agreement);
            }

            agreement.Status = agreementInVipps.Status.ToAgreementStatus();

            if (agreement.Status == Entities.AgreementStatus.ACTIVE)
            {
                agreement.ConfirmationUrl = string.Empty;
            }
        }

        _dbContext.SaveChanges();
    }

    public void UpdateAgreementCharges()
    {
        var agreementsThatAreDue = _dbContext.Agreements
            .Where(a => DateOnly.FromDateTime(_dateTimeNowProvider.Now) >= a.NextChargeDate)
            .ToList();

        foreach (var agreement in agreementsThatAreDue)
        {
            _backgroundJobClient.Enqueue(() => UpdateAgreementCharges(agreement.Id));
        }
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
            _logger.LogWarning("Job was triggered to update agreement charges on a job that is not due.");
            return;
        }

        var vippsAgreement = await _vippsApiClient.GetAgreement(agreement.Id);

        if (vippsAgreement.Status == VippsAgreementStatus.Active)
        {
            var nextCharge = await _vippsApiClient.GetCharge(agreement.Id, agreement.NextChargeId);

            if (nextCharge.Status == ChargeStatus.CHARGED)
            {
                _logger.LogWarning("Due charge for agreement was already charged. This should not happen.");
                await CreateAndStoreNewCharge(agreement, vippsAgreement);
            }
            else if (nextCharge.Status == ChargeStatus.RESERVED)
            {
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
                    throw new Exception($"Failed to capture charge.");
                }
            }
            else
            {
                _logger.LogWarning("Due charge for agreement was not charged and not reserved. Status was {status}. Will retry, possibly forever.", nextCharge.Status);
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

        if (vippsAgreement.Campaign != null)
        {
            var campaign = vippsAgreement.Campaign;

            if (campaign.Type == VippsCampaignType.PeriodCampaign)
            {
                var periodEndDate = GetNextChargeDate(DateOnly.FromDateTime(vippsAgreement.Start!.Value), campaign.Period!.Unit, campaign.Period!.Count);

                if (nowDateOnly < periodEndDate)
                {
                    // Next charge should be full price at the end of the campaign.
                    return (periodEndDate, vippsAgreement.Pricing.Amount);
                }
            }
            else if (campaign.Type == VippsCampaignType.PriceCampaign && now < campaign.End)
            {
                // Next charge is still within campaign
                return (
                    GetNextChargeDate(nowDateOnly, vippsAgreement.Interval.Unit, vippsAgreement.Interval.Count),
                    campaign.Price
                );
            }
            else if (campaign.Type == VippsCampaignType.EventCampaign || campaign.Type == VippsCampaignType.FullFlexCampaign)
            {
                throw new Exception("Unsupported campaign type");
            }
        }

        var nextChargeDate = GetNextChargeDate(nowDateOnly, vippsAgreement.Interval.Unit, vippsAgreement.Interval.Count);
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
