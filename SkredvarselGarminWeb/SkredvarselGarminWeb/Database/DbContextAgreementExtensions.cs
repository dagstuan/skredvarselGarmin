using Microsoft.EntityFrameworkCore;

using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Database;

public static class DbContextAgreementExtensions
{
    public static List<Agreement> GetAgreementsThatAreDue(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider) =>
        [.. dbContext.Agreements.Where(a => DateOnly.FromDateTime(dateTimeNowProvider.UtcNow) >= a.NextChargeDate)];

    public static List<Agreement> GetAgreementsDueInLessThan30Days(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider)
    {
        return dbContext.Agreements.Where(a =>
            (a.Status == AgreementStatus.ACTIVE ||
             a.Status == AgreementStatus.UNSUBSCRIBED) &&
            ((a.NextChargeDate.HasValue
                ? a.NextChargeDate.Value.ToDateTime(TimeOnly.MinValue)
                : DateTime.MaxValue) - dateTimeNowProvider.Now).Days <= 30)
            .ToList();
    }

    public static List<Agreement> GetActiveAgreementsDueInLessThan30DaysWithoutNextChargeId(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider)
    {
        return dbContext.Agreements.Where(a =>
            a.NextChargeId == null &&
            a.Status == AgreementStatus.ACTIVE &&
            ((a.NextChargeDate.HasValue
                ? a.NextChargeDate.Value.ToDateTime(TimeOnly.MinValue)
                : DateTime.MaxValue) - dateTimeNowProvider.Now).Days <= 30
            ).ToList();
    }

    public static List<Agreement> GetPendingAgreements(this SkredvarselDbContext dbContext) =>
        [.. dbContext.Agreements.Where(a => a.Status == AgreementStatus.PENDING)];

    public static bool DoesUserHaveActiveSubscription(this SkredvarselDbContext dbContext, string userId)
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
