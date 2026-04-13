using Stripe;

using StripeSubscriptionService = Stripe.SubscriptionService;

namespace SkredvarselGarminWeb.Services;

public class StripeGateway(IStripeClient stripeClient) : IStripeGateway
{
    public Customer GetCustomer(string customerId)
    {
        var service = new CustomerService(stripeClient);
        return service.Get(customerId);
    }

    public Subscription GetSubscription(string subscriptionId)
    {
        var service = new StripeSubscriptionService(stripeClient);
        return service.Get(subscriptionId);
    }
}
