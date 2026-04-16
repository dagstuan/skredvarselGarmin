using AwesomeAssertions;

using Microsoft.EntityFrameworkCore;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Tests;

public class DbContextUserExtensionsTests
{
    [Fact]
    public void GetFormerSubscribers_should_return_users_with_stopped_or_canceled_subscriptions()
    {
        using var dbContext = CreateDbContext();

        var formerVippsUser = CreateUser("former-vipps", "former.vipps@example.com", "Former Vipps");
        var formerStripeUser = CreateUser("former-stripe", "former.stripe@example.com", "Former Stripe");
        var activeUser = CreateUser("active-user", "active.user@example.com", "Active User");

        dbContext.Users.AddRange(formerVippsUser, formerStripeUser, activeUser);
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-stopped",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.STOPPED,
            Start = new DateOnly(2025, 12, 10),
            NextChargeDate = null,
            UserId = formerVippsUser.Id,
        });
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_canceled",
            Created = new DateTime(2026, 2, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.CANCELED,
            NextChargeDate = null,
            UserId = formerStripeUser.Id,
        });
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-active",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.ACTIVE,
            Start = new DateOnly(2026, 3, 10),
            NextChargeDate = new DateOnly(2026, 4, 10),
            UserId = activeUser.Id,
        });
        dbContext.SaveChanges();

        var result = dbContext.GetFormerSubscribers();

        result.Select(user => user.Id).Should().BeEquivalentTo([formerVippsUser.Id, formerStripeUser.Id]);
    }

    [Fact]
    public void GetFormerSubscribers_should_exclude_unsubscribed_users()
    {
        using var dbContext = CreateDbContext();

        var userWithUnsubscribedStripeSubscription = CreateUser("unsubscribed-stripe", "unsubscribed.stripe@example.com", "Unsubscribed Stripe");
        var userWithUnsubscribedVippsAgreement = CreateUser("unsubscribed-vipps", "unsubscribed.vipps@example.com", "Unsubscribed Vipps");

        dbContext.Users.AddRange(userWithUnsubscribedStripeSubscription, userWithUnsubscribedVippsAgreement);
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_unsubscribed",
            Created = new DateTime(2026, 2, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.UNSUBSCRIBED,
            NextChargeDate = new DateOnly(2026, 4, 10),
            UserId = userWithUnsubscribedStripeSubscription.Id,
        });
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-unsubscribed",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.UNSUBSCRIBED,
            Start = new DateOnly(2026, 2, 10),
            NextChargeDate = new DateOnly(2026, 4, 15),
            UserId = userWithUnsubscribedVippsAgreement.Id,
        });
        dbContext.SaveChanges();

        var result = dbContext.GetFormerSubscribers();

        result.Should().BeEmpty();
    }

    [Fact]
    public void GetFormerSubscribers_should_exclude_users_without_an_ended_subscription()
    {
        using var dbContext = CreateDbContext();

        var pendingVippsUser = CreateUser("pending-vipps", "pending.vipps@example.com", "Pending Vipps");
        var incompleteStripeUser = CreateUser("incomplete-stripe", "incomplete.stripe@example.com", "Incomplete Stripe");
        var pausedStripeUser = CreateUser("paused-stripe", "paused.stripe@example.com", "Paused Stripe");

        dbContext.Users.AddRange(pendingVippsUser, incompleteStripeUser, pausedStripeUser);
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-pending",
            CallbackId = Guid.NewGuid(),
            WatchKey = null,
            Created = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.PENDING,
            Start = new DateOnly(2026, 3, 10),
            NextChargeDate = null,
            UserId = pendingVippsUser.Id,
        });
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_incomplete",
            Created = new DateTime(2026, 3, 12, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.INCOMPLETE,
            NextChargeDate = null,
            UserId = incompleteStripeUser.Id,
        });
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_paused",
            Created = new DateTime(2026, 3, 15, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.PAUSED,
            NextChargeDate = null,
            UserId = pausedStripeUser.Id,
        });
        dbContext.SaveChanges();

        var result = dbContext.GetFormerSubscribers();

        result.Should().BeEmpty();
    }

    [Fact]
    public void GetFormerSubscribers_should_exclude_users_with_active_or_unsubscribed_subscriptions_even_if_they_have_ended_ones()
    {
        using var dbContext = CreateDbContext();

        var userWithStoppedAndActiveAgreement = CreateUser("stopped-active-vipps", "stopped.active.vipps@example.com", "Stopped Active Vipps");
        var userWithCanceledAndUnsubscribedStripe = CreateUser("canceled-unsubscribed-stripe", "canceled.unsubscribed.stripe@example.com", "Canceled Unsubscribed Stripe");

        dbContext.Users.AddRange(userWithStoppedAndActiveAgreement, userWithCanceledAndUnsubscribedStripe);
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-stopped",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.STOPPED,
            Start = new DateOnly(2025, 12, 10),
            NextChargeDate = null,
            UserId = userWithStoppedAndActiveAgreement.Id,
        });
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-active",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.ACTIVE,
            Start = new DateOnly(2026, 3, 10),
            NextChargeDate = new DateOnly(2026, 4, 10),
            UserId = userWithStoppedAndActiveAgreement.Id,
        });
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_canceled",
            Created = new DateTime(2026, 2, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.CANCELED,
            NextChargeDate = null,
            UserId = userWithCanceledAndUnsubscribedStripe.Id,
        });
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_unsubscribed",
            Created = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.UNSUBSCRIBED,
            NextChargeDate = new DateOnly(2026, 4, 20),
            UserId = userWithCanceledAndUnsubscribedStripe.Id,
        });
        dbContext.SaveChanges();

        var result = dbContext.GetFormerSubscribers();

        result.Should().BeEmpty();
    }

    [Fact]
    public void IsFormerSubscriber_should_return_true_for_a_user_with_only_stopped_or_canceled_subscriptions()
    {
        using var dbContext = CreateDbContext();

        var formerSubscriber = CreateUser("former-user", "former.user@example.com", "Former User");

        dbContext.Users.Add(formerSubscriber);
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-stopped",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.STOPPED,
            Start = new DateOnly(2025, 12, 10),
            NextChargeDate = null,
            UserId = formerSubscriber.Id,
        });
        dbContext.SaveChanges();

        var result = dbContext.IsFormerSubscriber(formerSubscriber.Id);

        result.Should().BeTrue();
    }

    [Fact]
    public void IsFormerSubscriber_should_return_false_for_a_user_with_any_non_ended_subscription()
    {
        using var dbContext = CreateDbContext();

        var user = CreateUser("current-user", "current.user@example.com", "Current User");

        dbContext.Users.Add(user);
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-stopped",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.STOPPED,
            Start = new DateOnly(2025, 12, 10),
            NextChargeDate = null,
            UserId = user.Id,
        });
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_trialing",
            Created = new DateTime(2026, 3, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.TRIALING,
            NextChargeDate = new DateOnly(2027, 5, 10),
            UserId = user.Id,
        });
        dbContext.SaveChanges();

        var result = dbContext.IsFormerSubscriber(user.Id);

        result.Should().BeFalse();
    }

    private static SkredvarselDbContext CreateDbContext()
    {
        var dbContextOptions = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase($"DbContextUserExtensionsTests-{Guid.NewGuid()}")
            .Options;

        var dbContext = new SkredvarselDbContext(dbContextOptions);
        dbContext.Database.EnsureCreated();

        return dbContext;
    }

    private static User CreateUser(string id, string email, string name)
    {
        return new User
        {
            Id = id,
            Email = email,
            Name = name,
            CreatedDate = new DateOnly(2025, 1, 1),
            LastLoggedIn = new DateOnly(2026, 4, 1),
        };
    }
}
