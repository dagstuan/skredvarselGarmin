using Stripe;
using Stripe.Checkout;

using StripeSubscriptionService = Stripe.SubscriptionService;

namespace SkredvarselGarminWeb.Services;

public class StripeGateway(IStripeClient stripeClient) : IStripeGateway
{
    public Customer GetCustomer(string customerId)
    {
        var service = new CustomerService(stripeClient);
        return service.Get(customerId);
    }

    public Session GetCheckoutSession(string sessionId)
    {
        var service = new SessionService(stripeClient);
        return service.Get(sessionId);
    }

    public Subscription GetSubscription(string subscriptionId)
    {
        var service = new StripeSubscriptionService(stripeClient);
        return service.Get(subscriptionId);
    }

    public Subscription UpdateSubscriptionTrialEnd(string subscriptionId, DateTime trialEnd)
    {
        var service = new StripeSubscriptionService(stripeClient);

        return service.Update(subscriptionId, new SubscriptionUpdateOptions
        {
            TrialEnd = trialEnd,
            ProrationBehavior = "none",
        });
    }
}
