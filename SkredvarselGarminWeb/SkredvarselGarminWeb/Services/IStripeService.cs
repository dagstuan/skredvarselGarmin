using Stripe;
using Stripe.Checkout;

using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IStripeService
{
    User GetOrCreateUserForCheckoutSession(Session session);
    void StoreNewSubscriptionIfNotExists(Session session);
    void HandleWebhook(Event stripeEvent);
}
