using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.VippsApi;
using Hangfire;

using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Hangfire;

public class HangfireService
{
    private readonly SkredvarselDbContext _dbContext;
    private readonly IVippsApiClient _vippsApiClient;
    private readonly IBackgroundJobClient _backgroundJobClient;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;
    private readonly ISubscriptionService _subscriptionService;
    private readonly ILogger<HangfireService> _logger;

    public HangfireService(
        SkredvarselDbContext dbContext,
        IVippsApiClient vippsApiClient,
        IBackgroundJobClient backgroundJobClient,
        IDateTimeNowProvider dateTimeNowProvider,
        ISubscriptionService subscriptionService,
        ILogger<HangfireService> logger)
    {
        _dbContext = dbContext;
        _vippsApiClient = vippsApiClient;
        _backgroundJobClient = backgroundJobClient;
        _dateTimeNowProvider = dateTimeNowProvider;
        _subscriptionService = subscriptionService;
        _logger = logger;
    }

    public async Task UpdatePendingAgreements()
    {
        var pendingAgreementsInDb = _dbContext.GetPendingAgreements();

        foreach (var agreement in pendingAgreementsInDb)
        {
            var vippsAgreement = await _vippsApiClient.GetAgreement(agreement.Id);

            if (vippsAgreement.Status == VippsAgreementStatus.Active)
            {
                _logger.LogInformation("Setting pending agreement {agreementId} as active with hangfire", agreement.Id);
                agreement.SetAsActive();
            }
        }

        _dbContext.SaveChanges();
    }

    public async Task RemoveStalePendingAgreements()
    {
        var pendingAgreementsInDb = _dbContext.Agreements
            .Where(a => a.Status == Entities.AgreementStatus.PENDING)
            .Where(a => a.Created < DateTime.UtcNow.AddMinutes(-10))
            .ToList();

        foreach (var agreement in pendingAgreementsInDb)
        {
            var vippsAgreement = await _vippsApiClient.GetAgreement(agreement.Id);

            if (vippsAgreement.Status == VippsAgreementStatus.Expired ||
                vippsAgreement.Status == VippsAgreementStatus.Stopped)
            {
                _logger.LogInformation("Deleting stale agreement {agreementId} since it was expired in Vipps.", agreement.Id);
                _dbContext.Remove(agreement);
            }
        }

        _dbContext.SaveChanges();
    }

    public void UpdateAgreementCharges()
    {
        var agreementsThatAreDue = _dbContext.GetAgreementsThatAreDue(_dateTimeNowProvider);

        foreach (var agreement in agreementsThatAreDue)
        {
            _backgroundJobClient.Enqueue(() => _subscriptionService.UpdateAgreementCharges(agreement.Id));
        }
    }

    public void RemoveStaleWatchAddRequests()
    {
        var staleWatchAddRequests = _dbContext.WatchAddRequests
            .Where(a => a.Created < DateTime.UtcNow.AddMinutes(-10))
            .ToList();

        _dbContext.RemoveRange(staleWatchAddRequests);
        _dbContext.SaveChanges();
    }
}
