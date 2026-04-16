namespace SkredvarselGarminWeb.Entities.Extensions;

public static class StripeSubscriptionExtensions
{
    public static bool IsActive(this StripeSubscriptionStatus status)
    {
        return status is StripeSubscriptionStatus.ACTIVE or StripeSubscriptionStatus.TRIALING;
    }

    public static bool IsActiveOrUnsubscribed(this StripeSubscriptionStatus status)
    {
        return status == StripeSubscriptionStatus.UNSUBSCRIBED || status.IsActive();
    }

    public static IQueryable<StripeSubscription> WhereActive(this IQueryable<StripeSubscription> query)
    {
        return query.Where(ss =>
            ss.Status == StripeSubscriptionStatus.ACTIVE ||
            ss.Status == StripeSubscriptionStatus.TRIALING);
    }

    public static IQueryable<StripeSubscription> WhereActiveOrUnsubscribed(this IQueryable<StripeSubscription> query)
    {
        return query.Where(ss =>
            ss.Status == StripeSubscriptionStatus.UNSUBSCRIBED ||
            ss.Status == StripeSubscriptionStatus.ACTIVE ||
            ss.Status == StripeSubscriptionStatus.TRIALING);
    }
}
