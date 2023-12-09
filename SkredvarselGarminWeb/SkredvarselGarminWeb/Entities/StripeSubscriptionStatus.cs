namespace SkredvarselGarminWeb.Entities;

public enum StripeSubscriptionStatus
{
    ACTIVE = 0,
    UNSUBSCRIBED = 1,
    CANCELED = 2,
    INCOMPLETE = 3,
    INCOMPLETE_EXPIRED = 4,
    PAST_DUE = 5,
    PAUSED = 6,
    TRIALING = 7,
    UNPAID = 8,
}
