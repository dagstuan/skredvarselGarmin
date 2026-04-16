using Stripe;
using Stripe.Checkout;

namespace SkredvarselGarminWeb.Services;

public interface IStripeGateway
{
    Customer GetCustomer(string customerId);
    Session GetCheckoutSession(string sessionId);
    Subscription GetSubscription(string subscriptionId);
    Subscription UpdateSubscriptionTrialEnd(string subscriptionId, DateTime trialEnd);
}
