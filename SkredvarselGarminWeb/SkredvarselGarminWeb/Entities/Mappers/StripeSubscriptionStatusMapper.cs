using System.ComponentModel;

using Stripe;

namespace SkredvarselGarminWeb.Entities.Mappers;

public static class StripeSubscriptionStatusMapper
{
    public static StripeSubscriptionStatus ToStripeSubscriptionStatus(this Subscription subscription) => (subscription.Status, subscription.CancelAtPeriodEnd) switch
    {
        ("active", false) => StripeSubscriptionStatus.ACTIVE,
        ("active", true) => StripeSubscriptionStatus.UNSUBSCRIBED,
        ("canceled", false) => StripeSubscriptionStatus.CANCELED,
        ("incomplete", false) => StripeSubscriptionStatus.INCOMPLETE,
        ("incomplete_expired", false) => StripeSubscriptionStatus.INCOMPLETE_EXPIRED,
        ("past_due", false) => StripeSubscriptionStatus.PAST_DUE,
        ("paused", false) => StripeSubscriptionStatus.PAUSED,
        ("trialing", false) => StripeSubscriptionStatus.TRIALING,
        ("unpaid", false) => StripeSubscriptionStatus.UNPAID,
        _ => throw new InvalidEnumArgumentException(nameof(subscription.Status))
    };
}
