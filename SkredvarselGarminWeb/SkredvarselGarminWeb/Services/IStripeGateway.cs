using Stripe;

namespace SkredvarselGarminWeb.Services;

public interface IStripeGateway
{
    Customer GetCustomer(string customerId);
    Subscription GetSubscription(string subscriptionId);
}
