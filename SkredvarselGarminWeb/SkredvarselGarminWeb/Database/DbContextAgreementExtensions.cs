using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Database;

public static class DbContextAgreementExtensions
{
    public static List<Agreement> GetAgreementsThatAreDue(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider) =>
        [.. dbContext.Agreements.Where(a => DateOnly.FromDateTime(dateTimeNowProvider.UtcNow) >= a.NextChargeDate)];

    public static List<Agreement> GetPendingAgreements(this SkredvarselDbContext dbContext) =>
        [.. dbContext.Agreements.Where(a => a.Status == AgreementStatus.PENDING)];

    public static bool DoesUserHaveActiveAgreement(this SkredvarselDbContext dbContext, string userId)
    {
        var activeOrUnsubbedVippsAgreements = dbContext.Agreements
            .Where(a => a.UserId == userId)
            .Any(a => a.Status == AgreementStatus.ACTIVE || a.Status == AgreementStatus.UNSUBSCRIBED);

        var activeOrUnsubbedStripeSubscriptions = dbContext.StripeSubscriptions
            .Where(ss => ss.UserId == userId)
            .Any(ss => ss.Status == StripeSubscriptionStatus.ACTIVE || ss.Status == StripeSubscriptionStatus.UNSUBSCRIBED);

        return activeOrUnsubbedVippsAgreements || activeOrUnsubbedStripeSubscriptions;
    }
}
