using System.ComponentModel;

using Stripe;

namespace SkredvarselGarminWeb.Entities.Mappers;

public static class StripeSubscriptionStatusMapper
{
    public static StripeSubscriptionStatus ToStripeSubscriptionStatus(this Subscription subscription)
    {
        if (subscription.Status == "canceled")
        {
            return StripeSubscriptionStatus.CANCELED;
        }

        if ((subscription.CancelAtPeriodEnd || subscription.CancelAt != null) && subscription.Status is "active" or "trialing")
        {
            return StripeSubscriptionStatus.UNSUBSCRIBED;
        }

        return subscription.Status switch
        {
            "active" => StripeSubscriptionStatus.ACTIVE,
            "incomplete" => StripeSubscriptionStatus.INCOMPLETE,
            "incomplete_expired" => StripeSubscriptionStatus.INCOMPLETE_EXPIRED,
            "past_due" => StripeSubscriptionStatus.PAST_DUE,
            "paused" => StripeSubscriptionStatus.PAUSED,
            "trialing" => StripeSubscriptionStatus.TRIALING,
            "unpaid" => StripeSubscriptionStatus.UNPAID,
            _ => throw new InvalidEnumArgumentException(nameof(subscription.Status))
        };
    }
}
