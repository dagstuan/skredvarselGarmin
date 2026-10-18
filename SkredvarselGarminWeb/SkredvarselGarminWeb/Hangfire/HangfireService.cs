using Hangfire;

using Microsoft.Extensions.Options;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VippsApi;

using EntityAgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;

namespace SkredvarselGarminWeb.Hangfire;

public class HangfireService(
    SkredvarselDbContext dbContext,
    IVippsApiClient vippsApiClient,
    IBackgroundJobClient backgroundJobClient,
    IDateTimeNowProvider dateTimeNowProvider,
    IVippsAgreementService vippsAgreementService,
    IResendAudienceSyncService resendAudienceSyncService,
    ISwedishForecastAreaSeeder swedishForecastAreaSeeder,
    IHttpClientFactory httpClientFactory,
    IOptions<HealthchecksOptions> healthchecksOptions,
    ILogger<HangfireService> logger)
{
    public const string HealthchecksHttpClientName = "Healthchecks";

    public async Task UpdatePendingAgreements()
    {
        var pendingAgreementsInDb = dbContext.Agreements
            .Where(a => a.Status == EntityAgreementStatus.PENDING)
            .Where(a => a.CallbackId != null)
            .ToList();

        foreach (var agreement in pendingAgreementsInDb)
        {
            var vippsAgreement = await vippsApiClient.GetAgreement(agreement.Id);

            if (vippsAgreement.Status == VippsAgreementStatus.Active)
            {
                logger.LogInformation("Setting pending agreement {agreementId} as active with hangfire", agreement.Id);
                agreement.SetAsActive();
            }
        }

        dbContext.SaveChanges();
    }

    public async Task RemoveStalePendingAgreements()
    {
        var pendingAgreementsInDb = dbContext.Agreements
            .Where(a => a.Status == EntityAgreementStatus.PENDING)
            .Where(a => a.Created < dateTimeNowProvider.UtcNow.AddMinutes(-15))
            .ToList();

        foreach (var agreement in pendingAgreementsInDb)
        {
            var vippsAgreement = await vippsApiClient.GetAgreement(agreement.Id);

            if (vippsAgreement.Status is
                VippsAgreementStatus.Expired or
                VippsAgreementStatus.Stopped)
            {
                logger.LogInformation("Deleting stale agreement {agreementId} since it was expired in Vipps.", agreement.Id);
                dbContext.Remove(agreement);
            }
            else if (vippsAgreement.Status == VippsAgreementStatus.Active)
            {
                logger.LogInformation("Agreement {agreementId} in vipps was active but no callback was received for 10 minutes. Stopping agreement.", agreement.Id);

                try
                {
                    await vippsAgreementService.StopAgreement(agreement.Id);
                    agreement.SetAsStopped();
                }
                catch (Exception e)
                {
                    logger.LogError(e, "Failed to stop agreement {agreementId} in Vipps. Hangfire will retry.", agreement.Id);
                }
            }
        }

        dbContext.SaveChanges();
    }

    public void UpdateAgreementCharges()
    {
        var agreementsThatAreDue = dbContext.GetAgreementsThatAreDue(dateTimeNowProvider);

        foreach (var agreement in agreementsThatAreDue)
        {
            backgroundJobClient.Enqueue(() => vippsAgreementService.UpdateAgreementCharges(agreement.Id));
        }
    }

    public void CreateNextChargeForAgreements()
    {
        var agreementsWithoutCharges = dbContext.GetActiveAgreementsDueInLessThan30DaysWithoutNextChargeId(dateTimeNowProvider);

        foreach (var agreement in agreementsWithoutCharges)
        {
            backgroundJobClient.Enqueue(() => vippsAgreementService.CreateNextChargeForAgreement(agreement.Id));
        }
    }

    public void RemoveStaleWatchAddRequests()
    {
        var staleWatchAddRequests = dbContext.WatchAddRequests
            .Where(a => a.Created < dateTimeNowProvider.UtcNow.AddMinutes(-25))
            .ToList();

        dbContext.RemoveRange(staleWatchAddRequests);
        dbContext.SaveChanges();
    }

    [DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task SeedSwedishForecastAreas(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await swedishForecastAreaSeeder.SeedAsync();
    }

    public void RemoveStaleUsers()
    {
        var staleUsers = dbContext.GetUsersNotLoggedInForAMonthWithoutAgreements(dateTimeNowProvider);

        foreach (var user in staleUsers)
        {
            logger.LogInformation("Removing stale user {userId} due to no logins for 1 month and no agreements.", user.Id);
            dbContext.Remove(user);
        }

        dbContext.SaveChanges();
    }

    [DisableConcurrentExecution(timeoutInSeconds: 1800)]
    public async Task SyncResendAudience(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await resendAudienceSyncService.SyncUsers(cancellationToken);
    }

    // Retrying a missed ping is pointless, the next scheduled ping replaces it.
    [AutomaticRetry(Attempts = 0)]
    public async Task PingHealthchecks(CancellationToken cancellationToken)
    {
        var pingUrl = healthchecksOptions.Value.PingUrl;
        if (string.IsNullOrEmpty(pingUrl))
        {
            throw new InvalidOperationException("Healthchecks:PingUrl is not configured.");
        }

        var client = httpClientFactory.CreateClient(HealthchecksHttpClientName);
        var response = await client.GetAsync(pingUrl, cancellationToken);
        response.EnsureSuccessStatusCode();
    }
}
