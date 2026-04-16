using Stripe;
using Stripe.Checkout;

using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IStripeService
{
    void FulfillCheckoutSession(string sessionId);
    User GetUserForFulfilledCheckoutSession(string sessionId);
    User GetOrCreateUserForCheckoutSession(Session session);
    void HandleWebhook(Event stripeEvent);
}
