using Hangfire;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VippsApi;

using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;

namespace SkredvarselGarminWeb.Hangfire;

public class HangfireService(
    SkredvarselDbContext dbContext,
    IVippsApiClient vippsApiClient,
    IBackgroundJobClient backgroundJobClient,
    IDateTimeNowProvider dateTimeNowProvider,
    IVippsAgreementService subscriptionService,
    ILogger<HangfireService> logger)
{
    public async Task UpdatePendingAgreements()
    {
        var pendingAgreementsInDb = dbContext.GetPendingAgreements();

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
            .Where(a => a.Status == Entities.AgreementStatus.PENDING)
            .Where(a => a.Created < dateTimeNowProvider.UtcNow.AddMinutes(-10))
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
        }

        dbContext.SaveChanges();
    }

    public void UpdateAgreementCharges()
    {
        var agreementsThatAreDue = dbContext.GetAgreementsThatAreDue(dateTimeNowProvider);

        foreach (var agreement in agreementsThatAreDue)
        {
            backgroundJobClient.Enqueue(() => subscriptionService.UpdateAgreementCharges(agreement.Id));
        }
    }

    public void CreateNextChargeForAgreements()
    {
        var agreementsWithoutCharges = dbContext.GetActiveAgreementsDueInLessThan30DaysWithoutNextChargeId(dateTimeNowProvider);

        foreach (var agreement in agreementsWithoutCharges)
        {
            backgroundJobClient.Enqueue(() => subscriptionService.CreateNextChargeForAgreement(agreement.Id));
        }
    }

    public void RemoveStaleWatchAddRequests()
    {
        var staleWatchAddRequests = dbContext.WatchAddRequests
            .Where(a => a.Created < dateTimeNowProvider.UtcNow.AddMinutes(-10))
            .ToList();

        dbContext.RemoveRange(staleWatchAddRequests);
        dbContext.SaveChanges();
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
}
