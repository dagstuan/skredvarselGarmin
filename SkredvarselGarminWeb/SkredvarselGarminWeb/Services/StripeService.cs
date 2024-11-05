using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Entities.Mappers;
using SkredvarselGarminWeb.Helpers;

using Stripe;
using Stripe.Checkout;

using StripeSubscriptionService = Stripe.SubscriptionService;

namespace SkredvarselGarminWeb.Services;

public class StripeService(
    SkredvarselDbContext dbContext,
    INotificationService notificationService,
    IDateTimeNowProvider dateTimeNowProvider,
    ILogger<StripeService> logger) : IStripeService
{
    private static Subscription GetStripeSubscription(string subscriptionId)
    {
        var service = new StripeSubscriptionService();
        return service.Get(subscriptionId);
    }

    public void HandleWebhook(Event stripeEvent)
    {
        logger.LogInformation("Received stripe webhook event {eventType}", stripeEvent.Type);


        // Handle the event
        if (stripeEvent.Type == EventTypes.CheckoutSessionCompleted)
        {
            var session = (Session)stripeEvent.Data.Object;
            StoreNewSubscriptionIfNotExists(session);
        }
        else if (
            stripeEvent.Type == EventTypes.CustomerSubscriptionUpdated ||
            stripeEvent.Type == EventTypes.CustomerSubscriptionDeleted ||
            stripeEvent.Type == EventTypes.CustomerSubscriptionPaused ||
            stripeEvent.Type == EventTypes.CustomerSubscriptionResumed)
        {
            var subscription = (Subscription)stripeEvent.Data.Object;
            HandleSubscriptionUpdated(subscription);
        }
        else
        {
            // Unexpected event type
            logger.LogWarning("Unhandled event type: {eventType}", stripeEvent.Type);
        }
    }

    public void StoreNewSubscriptionIfNotExists(Session session)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        var user = dbContext.Users.Single(u => u.Id == session.ClientReferenceId);
        var existingSubscription = dbContext.StripeSubscriptions.Find(session.SubscriptionId);

        if (existingSubscription != null)
        {
            transaction.Commit();
            return;
        }

        user.StripeCustomerId = session.CustomerId;

        var stripeSubscription = GetStripeSubscription(session.SubscriptionId);

        var status = stripeSubscription.ToStripeSubscriptionStatus();

        if (status == StripeSubscriptionStatus.ACTIVE)
        {
            _ = Task.Run(notificationService.NotifyUserSubscribed);
        }

        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            Created = dateTimeNowProvider.Now.ToUniversalTime(),
            SubscriptionId = session.SubscriptionId,
            UserId = user.Id,
            Status = status,
            NextChargeDate = DateOnly.FromDateTime(stripeSubscription.CurrentPeriodEnd)
        });

        dbContext.SaveChanges();

        transaction.Commit();
    }

    public void HandleSubscriptionUpdated(Subscription subscription)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        var subscriptionInDb = dbContext.StripeSubscriptions.SingleOrDefault(s => s.SubscriptionId == subscription.Id);

        if (subscriptionInDb == null)
        {
            logger.LogInformation("Received subscription updated event for subscription not in local database.");
            transaction.Commit();
            return;
        }

        subscriptionInDb.Status = subscription.ToStripeSubscriptionStatus();
        subscriptionInDb.NextChargeDate = DateOnly.FromDateTime(subscription.CurrentPeriodEnd);

        dbContext.SaveChanges();

        transaction.Commit();
    }
}
