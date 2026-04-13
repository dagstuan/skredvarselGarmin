using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Entities.Mappers;
using SkredvarselGarminWeb.Helpers;

using Microsoft.EntityFrameworkCore;

using Stripe;
using Stripe.Checkout;

namespace SkredvarselGarminWeb.Services;

public class StripeService(
    SkredvarselDbContext dbContext,
    IStripeGateway stripeGateway,
    INotificationService notificationService,
    IDateTimeNowProvider dateTimeNowProvider,
    ILogger<StripeService> logger) : IStripeService
{
    private sealed record CheckoutUserDetails(string? Email, string? Name);

    private static T? TryGetStripeValue<T>(Func<T?> getter)
    {
        try
        {
            return getter();
        }
        catch (NullReferenceException)
        {
            return default;
        }
    }

    private static CheckoutUserDetails ReadSessionUserDetails(Session session)
    {
        var email = session.CustomerEmail ?? TryGetStripeValue(() => session.CustomerDetails?.Email);
        var name = TryGetStripeValue(() => session.CustomerDetails?.Name);
        return new CheckoutUserDetails(email, name);
    }

    private CheckoutUserDetails GetUserDetailsForCheckoutSession(Session session, User? user)
    {
        var userDetails = ReadSessionUserDetails(session);

        if (user != null || !string.IsNullOrWhiteSpace(userDetails.Email) || string.IsNullOrWhiteSpace(session.CustomerId))
        {
            return userDetails;
        }

        // Stripe may omit customer details on the checkout session, so fall back to the customer record
        // when we still need an email to resolve or create the local user.
        var customer = stripeGateway.GetCustomer(session.CustomerId);

        return new CheckoutUserDetails(customer.Email, userDetails.Name ?? customer.Name);
    }

    private User? FindUserBySessionIdentifiers(Session session)
    {
        var user = !string.IsNullOrWhiteSpace(session.ClientReferenceId)
            ? dbContext.GetUserByIdOrNull(session.ClientReferenceId)
            : null;

        return user ?? (!string.IsNullOrWhiteSpace(session.CustomerId)
            ? dbContext.Users.SingleOrDefault(existingUser => existingUser.StripeCustomerId == session.CustomerId)
            : null);
    }

    private User CreateUserFromSession(Session session, CheckoutUserDetails userDetails)
    {
        if (string.IsNullOrWhiteSpace(userDetails.Email))
        {
            throw new Exception($"Unable to resolve user for Stripe checkout session {session.Id} because no email was present.");
        }

        var dateNow = DateOnly.FromDateTime(dateTimeNowProvider.Now);

        return new User
        {
            Id = session.ClientReferenceId ?? Guid.NewGuid().ToString(),
            Name = userDetails.Name,
            Email = userDetails.Email,
            CreatedDate = dateNow,
            LastLoggedIn = dateNow,
            StripeCustomerId = session.CustomerId,
        };
    }

    public User GetOrCreateUserForCheckoutSession(Session session)
    {
        var userByIdentifiers = FindUserBySessionIdentifiers(session);
        var userDetails = GetUserDetailsForCheckoutSession(session, userByIdentifiers);
        var userByEmail = !string.IsNullOrWhiteSpace(userDetails.Email)
            ? dbContext.GetUserByEmailOrNull(userDetails.Email)
            : null;

        var resolvedUser = userByIdentifiers ?? userByEmail;

        if (resolvedUser == null)
        {
            resolvedUser = CreateUserFromSession(session, userDetails);
            dbContext.Users.Add(resolvedUser);
        }

        if (!string.IsNullOrWhiteSpace(userDetails.Email))
        {
            resolvedUser.Email = userDetails.Email;
        }

        if (!string.IsNullOrWhiteSpace(userDetails.Name))
        {
            resolvedUser.Name = userDetails.Name;
        }

        resolvedUser.LastLoggedIn = DateOnly.FromDateTime(dateTimeNowProvider.Now);

        if (!string.IsNullOrWhiteSpace(session.CustomerId))
        {
            resolvedUser.StripeCustomerId = session.CustomerId;
        }

        dbContext.SaveChanges();

        return resolvedUser;
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
            stripeEvent.Type is
                EventTypes.CustomerSubscriptionUpdated or
                EventTypes.CustomerSubscriptionDeleted or
                EventTypes.CustomerSubscriptionPaused or
                EventTypes.CustomerSubscriptionResumed)
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

        var user = GetOrCreateUserForCheckoutSession(session);

        var subscriptionId = session.SubscriptionId
            ?? throw new Exception($"Stripe checkout session {session.Id} did not contain a subscription id.");

        var existingSubscription = dbContext.StripeSubscriptions.Find(subscriptionId);

        if (existingSubscription != null)
        {
            transaction.Commit();
            return;
        }

        var stripeSubscription = stripeGateway.GetSubscription(subscriptionId);

        var status = stripeSubscription.ToStripeSubscriptionStatus();

        if (status == StripeSubscriptionStatus.ACTIVE)
        {
            _ = Task.Run(notificationService.NotifyUserSubscribed);
        }

        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            Created = dateTimeNowProvider.Now.ToUniversalTime(),
            SubscriptionId = subscriptionId,
            UserId = user.Id,
            Status = status,
            NextChargeDate = DateOnly.FromDateTime(stripeSubscription.Items.Data[0].CurrentPeriodEnd)
        });

        dbContext.SaveChanges();

        transaction.Commit();
    }

    public void HandleSubscriptionUpdated(Subscription subscription)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        var latestSubscription = stripeGateway.GetSubscription(subscription.Id);

        logger.LogInformation(
            "Processing stripe subscription update for {subscriptionId} with status {status} and cancelAtPeriodEnd {cancelAtPeriodEnd}.",
            latestSubscription.Id,
            latestSubscription.Status,
            latestSubscription.CancelAtPeriodEnd);

        var subscriptionInDb = dbContext.StripeSubscriptions.SingleOrDefault(s => s.SubscriptionId == latestSubscription.Id);

        if (subscriptionInDb == null)
        {
            logger.LogInformation(
                "Received subscription updated event for subscription {subscriptionId} not in local database.",
                latestSubscription.Id);
            transaction.Commit();
            return;
        }

        var updatedStatus = latestSubscription.ToStripeSubscriptionStatus();

        logger.LogInformation(
            "Updating local stripe subscription {subscriptionId} from {previousStatus} to {updatedStatus}.",
            latestSubscription.Id,
            subscriptionInDb.Status,
            updatedStatus);

        subscriptionInDb.Status = updatedStatus;
        subscriptionInDb.NextChargeDate = DateOnly.FromDateTime(latestSubscription.Items.Data[0].CurrentPeriodEnd);

        dbContext.SaveChanges();

        transaction.Commit();
    }
}
