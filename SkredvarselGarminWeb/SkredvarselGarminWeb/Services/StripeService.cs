using System.Data;
using System.Security.Cryptography;
using System.Text;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Entities.Mappers;
using SkredvarselGarminWeb.Helpers;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

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

    private User? FindUserByStripeCustomerId(string? stripeCustomerId)
    {
        return !string.IsNullOrWhiteSpace(stripeCustomerId)
            ? dbContext.Users.SingleOrDefault(existingUser => existingUser.StripeCustomerId == stripeCustomerId)
            : null;
    }

    private User? FindUserBySessionIdentifiers(Session session)
    {
        var userByStripeCustomerId = FindUserByStripeCustomerId(session.CustomerId);
        var userByClientReferenceId = !string.IsNullOrWhiteSpace(session.ClientReferenceId)
            ? dbContext.GetUserByIdOrNull(session.ClientReferenceId)
            : null;

        if (userByStripeCustomerId != null &&
            userByClientReferenceId != null &&
            userByStripeCustomerId.Id != userByClientReferenceId.Id)
        {
            logger.LogWarning(
                "Stripe checkout session {sessionId} referenced user {clientReferenceUserId}, but customer {stripeCustomerId} already belongs to user {stripeCustomerUserId}. Reusing the existing Stripe customer owner.",
                session.Id,
                userByClientReferenceId.Id,
                session.CustomerId,
                userByStripeCustomerId.Id);
        }

        return userByStripeCustomerId ?? userByClientReferenceId;
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

    private static long CreateAdvisoryLockKey(string resourceType, string resourceId)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes($"{resourceType}:{resourceId}"));
        return BitConverter.ToInt64(hash, 0);
    }

    private void AcquireTransactionScopedAdvisoryLock(string resourceType, string resourceId)
    {
        if (!string.Equals(dbContext.Database.ProviderName, "Npgsql.EntityFrameworkCore.PostgreSQL", StringComparison.Ordinal))
        {
            return;
        }

        var transaction = dbContext.Database.CurrentTransaction
            ?? throw new InvalidOperationException("A database transaction is required before acquiring a Stripe advisory lock.");

        var connection = dbContext.Database.GetDbConnection();
        var shouldCloseConnection = connection.State != ConnectionState.Open;

        if (shouldCloseConnection)
        {
            connection.Open();
        }

        try
        {
            using var command = connection.CreateCommand();
            command.Transaction = transaction.GetDbTransaction();
            command.CommandText = "SELECT pg_advisory_xact_lock(@lock_key);";

            var parameter = command.CreateParameter();
            parameter.ParameterName = "lock_key";
            parameter.Value = CreateAdvisoryLockKey(resourceType, resourceId);
            command.Parameters.Add(parameter);

            _ = command.ExecuteScalar();
        }
        finally
        {
            if (shouldCloseConnection)
            {
                connection.Close();
            }
        }
    }

    private StripeCheckoutSessionFulfillment? GetCheckoutSessionFulfillment(string sessionId)
    {
        return dbContext.StripeCheckoutSessionFulfillments
            .Include(f => f.User)
            .SingleOrDefault(f => f.SessionId == sessionId);
    }

    private bool EnsureStripeSubscriptionExists(Session session, User user)
    {
        var subscriptionId = session.SubscriptionId
            ?? throw new Exception($"Stripe checkout session {session.Id} did not contain a subscription id.");

        AcquireTransactionScopedAdvisoryLock("stripe-subscription", subscriptionId);

        var existingSubscription = dbContext.StripeSubscriptions.Find(subscriptionId);

        if (existingSubscription != null)
        {
            return false;
        }

        var stripeSubscription = stripeGateway.GetSubscription(subscriptionId);

        var formerSubscriberExtraMonths = dbContext.IsFormerSubscriber(user.Id)
            ? dbContext.GetFormerSubscriberExtraMonths()
            : 0;

        if (formerSubscriberExtraMonths > 0)
        {
            stripeSubscription = stripeGateway.UpdateSubscriptionTrialEnd(
                subscriptionId,
                stripeSubscription.Items.Data[0].CurrentPeriodEnd.AddMonths(formerSubscriberExtraMonths));
        }

        var status = stripeSubscription.ToStripeSubscriptionStatus();

        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            Created = dateTimeNowProvider.Now.ToUniversalTime(),
            SubscriptionId = subscriptionId,
            UserId = user.Id,
            Status = status,
            NextChargeDate = DateOnly.FromDateTime(stripeSubscription.Items.Data[0].CurrentPeriodEnd)
        });

        return status.IsActive();
    }

    public void FulfillCheckoutSession(string sessionId)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        AcquireTransactionScopedAdvisoryLock("stripe-checkout-session", sessionId);

        var existingFulfillment = GetCheckoutSessionFulfillment(sessionId);

        if (existingFulfillment != null)
        {
            transaction.Commit();
            return;
        }

        var session = stripeGateway.GetCheckoutSession(sessionId);

        if (!string.IsNullOrWhiteSpace(session.CustomerId))
        {
            AcquireTransactionScopedAdvisoryLock("stripe-customer", session.CustomerId);
        }

        var user = GetOrCreateUserForCheckoutSession(session);
        var wasSubscriptionCreated = EnsureStripeSubscriptionExists(session, user);

        dbContext.StripeCheckoutSessionFulfillments.Add(new StripeCheckoutSessionFulfillment
        {
            SessionId = sessionId,
            UserId = user.Id,
            SubscriptionId = session.SubscriptionId
                ?? throw new Exception($"Stripe checkout session {sessionId} did not contain a subscription id."),
            FulfilledAt = dateTimeNowProvider.Now.ToUniversalTime()
        });

        dbContext.SaveChanges();
        transaction.Commit();

        if (wasSubscriptionCreated)
        {
            _ = Task.Run(notificationService.NotifyUserSubscribed);
        }
    }

    public User GetUserForFulfilledCheckoutSession(string sessionId)
    {
        return GetCheckoutSessionFulfillment(sessionId)?.User
            ?? throw new Exception($"Stripe checkout session {sessionId} has not been fulfilled.");
    }

    public User GetOrCreateUserForCheckoutSession(Session session)
    {
        var userByIdentifiers = FindUserBySessionIdentifiers(session);
        var userDetails = GetUserDetailsForCheckoutSession(session, userByIdentifiers);
        var userByEmail = !string.IsNullOrWhiteSpace(userDetails.Email)
            ? dbContext.GetUserByEmailOrNull(userDetails.Email)
            : null;

        if (userByIdentifiers != null &&
            userByEmail != null &&
            userByIdentifiers.Id != userByEmail.Id &&
            !string.IsNullOrWhiteSpace(session.CustomerId) &&
            string.Equals(userByIdentifiers.StripeCustomerId, session.CustomerId, StringComparison.Ordinal))
        {
            logger.LogWarning(
                "Stripe checkout session {sessionId} matched email {email} to user {emailUserId}, but customer {stripeCustomerId} is already linked to user {stripeCustomerUserId}. Reusing the existing Stripe customer owner.",
                session.Id,
                userDetails.Email,
                userByEmail.Id,
                session.CustomerId,
                userByIdentifiers.Id);
        }

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
            FulfillCheckoutSession(session.Id);
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
