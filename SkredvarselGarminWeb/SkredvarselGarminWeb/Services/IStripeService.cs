using Stripe;
using Stripe.Checkout;

namespace SkredvarselGarminWeb.Services;

public interface IStripeService
{
    void StoreNewSubscriptionIfNotExists(Session session);
    void HandleWebhook(Event stripeEvent);
}
