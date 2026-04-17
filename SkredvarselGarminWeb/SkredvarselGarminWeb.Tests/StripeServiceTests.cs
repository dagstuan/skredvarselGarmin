using AwesomeAssertions;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Logging;

using NSubstitute;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Entities.Mappers;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;

using Stripe;

namespace SkredvarselGarminWeb.Tests;

public class StripeServiceTests
{
    private readonly SkredvarselDbContext _dbContext;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;
    private readonly IStripeGateway _stripeGateway;
    private readonly StripeService _stripeService;

    public StripeServiceTests()
    {
        var dbContextOptions = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase($"StripeServiceTests-{Guid.NewGuid()}")
            .ConfigureWarnings(builder => builder.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        _dbContext = new SkredvarselDbContext(dbContextOptions);
        _dbContext.Database.EnsureDeleted();
        _dbContext.Database.EnsureCreated();

        _dateTimeNowProvider = Substitute.For<IDateTimeNowProvider>();
        _dateTimeNowProvider.Now.Returns(new DateTime(2026, 4, 12, 12, 0, 0, DateTimeKind.Utc));
        _stripeGateway = Substitute.For<IStripeGateway>();

        _stripeService = new StripeService(
            _dbContext,
            _stripeGateway,
            Substitute.For<INotificationService>(),
            _dateTimeNowProvider,
            Substitute.For<ILogger<StripeService>>());
    }

    [Fact]
    public void GetOrCreateUserForCheckoutSession_should_create_new_user_for_anonymous_checkout()
    {
        var session = new Stripe.Checkout.Session
        {
            Id = "cs_123",
            CustomerId = "cus_123",
            CustomerEmail = "new.user@example.com"
        };

        var user = _stripeService.GetOrCreateUserForCheckoutSession(session);

        user.Id.Should().NotBeNullOrWhiteSpace();
        user.Email.Should().Be("new.user@example.com");
        user.StripeCustomerId.Should().Be("cus_123");
        _dbContext.Users.Should().ContainSingle(existingUser => existingUser.Id == user.Id);
    }

    [Fact]
    public void GetOrCreateUserForCheckoutSession_should_reuse_existing_user_with_same_stripe_customer_id()
    {
        _dbContext.Users.Add(new User
        {
            Id = "existing-user",
            Email = "existing.user@example.com",
            Name = "Existing User",
            CreatedDate = new DateOnly(2026, 1, 1),
            LastLoggedIn = new DateOnly(2026, 1, 1),
            StripeCustomerId = "cus_456"
        });
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_456",
            CustomerId = "cus_456"
        };

        var user = _stripeService.GetOrCreateUserForCheckoutSession(session);

        user.Id.Should().Be("existing-user");
        user.StripeCustomerId.Should().Be("cus_456");
        _dbContext.Users.Should().ContainSingle(existingUser => existingUser.Id == "existing-user");
    }

    [Fact]
    public void GetOrCreateUserForCheckoutSession_should_prefer_existing_stripe_customer_owner_over_client_reference_user()
    {
        _dbContext.Users.AddRange(
            new User
            {
                Id = "client-reference-user",
                Email = "client.reference@example.com",
                Name = "Client Reference User",
                CreatedDate = new DateOnly(2026, 1, 1),
                LastLoggedIn = new DateOnly(2026, 1, 1),
            },
            new User
            {
                Id = "stripe-owner-user",
                Email = "stripe.owner@example.com",
                Name = "Stripe Owner User",
                CreatedDate = new DateOnly(2026, 1, 1),
                LastLoggedIn = new DateOnly(2026, 1, 1),
                StripeCustomerId = "cus_conflict"
            });
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_conflict",
            ClientReferenceId = "client-reference-user",
            CustomerId = "cus_conflict"
        };

        var user = _stripeService.GetOrCreateUserForCheckoutSession(session);

        user.Id.Should().Be("stripe-owner-user");
        _dbContext.Users.Single(existingUser => existingUser.Id == "client-reference-user").StripeCustomerId.Should().BeNull();
        _dbContext.Users.Single(existingUser => existingUser.Id == "stripe-owner-user").StripeCustomerId.Should().Be("cus_conflict");
    }

    [Fact]
    public void GetOrCreateUserForCheckoutSession_should_fall_back_to_customer_record_when_session_has_no_email()
    {
        _stripeGateway.GetCustomer("cus_missing_email").Returns(new Customer
        {
            Id = "cus_missing_email",
            Email = "gateway.user@example.com",
            Name = "Gateway User"
        });

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_missing_email",
            CustomerId = "cus_missing_email"
        };

        var user = _stripeService.GetOrCreateUserForCheckoutSession(session);

        user.Email.Should().Be("gateway.user@example.com");
        user.Name.Should().Be("Gateway User");
        user.StripeCustomerId.Should().Be("cus_missing_email");
        _stripeGateway.Received(1).GetCustomer("cus_missing_email");
    }

    [Fact]
    public void GetOrCreateUserForCheckoutSession_should_not_fetch_customer_when_user_is_already_resolved_by_identifier()
    {
        _dbContext.Users.Add(new User
        {
            Id = "existing-user",
            Email = "existing.user@example.com",
            Name = "Existing User",
            CreatedDate = new DateOnly(2026, 1, 1),
            LastLoggedIn = new DateOnly(2026, 1, 1),
            StripeCustomerId = "cus_existing"
        });
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_existing",
            CustomerId = "cus_existing"
        };

        var user = _stripeService.GetOrCreateUserForCheckoutSession(session);

        user.Id.Should().Be("existing-user");
        _stripeGateway.DidNotReceive().GetCustomer(Arg.Any<string>());
    }

    [Fact]
    public void GetOrCreateUserForCheckoutSession_should_throw_when_no_email_can_be_resolved()
    {
        _stripeGateway.GetCustomer("cus_no_email").Returns(new Customer
        {
            Id = "cus_no_email",
            Name = "Nameless Email"
        });

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_no_email",
            CustomerId = "cus_no_email"
        };

        var act = () => _stripeService.GetOrCreateUserForCheckoutSession(session);

        act.Should().Throw<Exception>()
            .WithMessage("*cs_no_email*no email was present*");
    }

    [Fact]
    public void FulfillCheckoutSession_should_only_fulfill_once_per_checkout_session()
    {
        var session = new Stripe.Checkout.Session
        {
            Id = "cs_fulfill_once",
            CustomerId = "cus_fulfill_once",
            CustomerEmail = "once@example.com",
            SubscriptionId = "sub_fulfill_once"
        };

        _stripeGateway.GetCheckoutSession("cs_fulfill_once").Returns(session);
        _stripeGateway.GetSubscription("sub_fulfill_once").Returns(CreateStripeSubscription(
            id: "sub_fulfill_once",
            status: "active",
            currentPeriodEnd: new DateTime(2027, 4, 12, 12, 0, 0, DateTimeKind.Utc)));
        _stripeGateway.UpdateSubscriptionTrialEnd(
            "sub_fulfill_once",
            new DateTime(2027, 5, 12, 12, 0, 0, DateTimeKind.Utc)).Returns(CreateStripeSubscription(
                id: "sub_fulfill_once",
                status: "trialing",
                currentPeriodEnd: new DateTime(2027, 5, 12, 12, 0, 0, DateTimeKind.Utc)));

        _stripeService.FulfillCheckoutSession("cs_fulfill_once");
        var firstUser = _stripeService.GetUserForFulfilledCheckoutSession("cs_fulfill_once");
        _stripeService.FulfillCheckoutSession("cs_fulfill_once");
        var secondUser = _stripeService.GetUserForFulfilledCheckoutSession("cs_fulfill_once");

        secondUser.Id.Should().Be(firstUser.Id);
        _stripeGateway.Received(1).GetCheckoutSession("cs_fulfill_once");
        _dbContext.StripeSubscriptions.Should().ContainSingle(subscription => subscription.SubscriptionId == "sub_fulfill_once");
        _dbContext.StripeCheckoutSessionFulfillments.Should().ContainSingle(fulfillment => fulfillment.SessionId == "cs_fulfill_once");
    }

    [Fact]
    public void FulfillCheckoutSession_should_not_create_duplicate_subscription_when_subscription_already_exists()
    {
        _dbContext.Users.Add(new User
        {
            Id = "existing-user",
            Email = "existing.user@example.com",
            Name = "Existing User",
            CreatedDate = new DateOnly(2026, 1, 1),
            LastLoggedIn = new DateOnly(2026, 1, 1),
            StripeCustomerId = "cus_existing"
        });
        _dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_existing",
            UserId = "existing-user",
            Status = StripeSubscriptionStatus.ACTIVE,
            Created = new DateTime(2026, 4, 1, 12, 0, 0, DateTimeKind.Utc),
            NextChargeDate = new DateOnly(2026, 5, 1)
        });
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_existing_sub",
            CustomerId = "cus_existing",
            SubscriptionId = "sub_existing"
        };

        _stripeGateway.GetCheckoutSession("cs_existing_sub").Returns(session);

        _stripeService.FulfillCheckoutSession("cs_existing_sub");

        _dbContext.StripeSubscriptions.Should().ContainSingle(subscription => subscription.SubscriptionId == "sub_existing");
        _dbContext.StripeCheckoutSessionFulfillments.Should().ContainSingle(fulfillment => fulfillment.SessionId == "cs_existing_sub");
        _stripeGateway.DidNotReceive().GetSubscription(Arg.Any<string>());
    }

    [Fact]
    public void FulfillCheckoutSession_should_extend_the_first_period_for_former_subscribers()
    {
        _dbContext.Users.Add(new User
        {
            Id = "former-user",
            Email = "former.user@example.com",
            Name = "Former User",
            CreatedDate = new DateOnly(2025, 1, 1),
            LastLoggedIn = new DateOnly(2026, 1, 1),
            StripeCustomerId = "cus_former"
        });
        _dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_old",
            UserId = "former-user",
            Status = StripeSubscriptionStatus.CANCELED,
            Created = new DateTime(2025, 4, 1, 12, 0, 0, DateTimeKind.Utc),
            NextChargeDate = null,
        });
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_former",
            CustomerId = "cus_former",
            SubscriptionId = "sub_new"
        };

        var initialSubscription = CreateStripeSubscription(
            id: "sub_new",
            status: "active",
            currentPeriodEnd: new DateTime(2027, 4, 12, 12, 0, 0, DateTimeKind.Utc));
        var extendedSubscription = CreateStripeSubscription(
            id: "sub_new",
            status: "trialing",
            currentPeriodEnd: new DateTime(2027, 5, 12, 12, 0, 0, DateTimeKind.Utc));

        _stripeGateway.GetCheckoutSession("cs_former").Returns(session);
        _stripeGateway.GetSubscription("sub_new").Returns(initialSubscription);
        _stripeGateway.UpdateSubscriptionTrialEnd(
            "sub_new",
            new DateTime(2027, 5, 12, 12, 0, 0, DateTimeKind.Utc)).Returns(extendedSubscription);

        _stripeService.FulfillCheckoutSession("cs_former");

        _stripeGateway.Received(1).UpdateSubscriptionTrialEnd(
            "sub_new",
            new DateTime(2027, 5, 12, 12, 0, 0, DateTimeKind.Utc));

        _dbContext.StripeSubscriptions.Should().ContainSingle(subscription =>
            subscription.SubscriptionId == "sub_new" &&
            subscription.Status == StripeSubscriptionStatus.TRIALING &&
            subscription.NextChargeDate == new DateOnly(2027, 5, 12));
    }

    [Fact]
    public void FulfillCheckoutSession_should_not_extend_the_first_period_for_non_former_subscribers()
    {
        _dbContext.Users.Add(new User
        {
            Id = "new-user",
            Email = "new.user@example.com",
            Name = "New User",
            CreatedDate = new DateOnly(2026, 1, 1),
            LastLoggedIn = new DateOnly(2026, 1, 1),
            StripeCustomerId = "cus_new"
        });
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_new",
            CustomerId = "cus_new",
            SubscriptionId = "sub_new"
        };

        _stripeGateway.GetSubscription("sub_new").Returns(CreateStripeSubscription(
            id: "sub_new",
            status: "active",
            currentPeriodEnd: new DateTime(2027, 4, 12, 12, 0, 0, DateTimeKind.Utc)));

        _stripeGateway.GetCheckoutSession("cs_new").Returns(session);

        _stripeService.FulfillCheckoutSession("cs_new");

        _stripeGateway.DidNotReceive().UpdateSubscriptionTrialEnd(Arg.Any<string>(), Arg.Any<DateTime>());
    }

    [Fact]
    public void FulfillCheckoutSession_should_not_extend_the_first_period_when_former_subscriber_extra_months_is_zero()
    {
        _dbContext.Users.Add(new User
        {
            Id = "former-user-disabled",
            Email = "former.disabled@example.com",
            Name = "Former User Disabled",
            CreatedDate = new DateOnly(2025, 1, 1),
            LastLoggedIn = new DateOnly(2026, 1, 1),
            StripeCustomerId = "cus_former_disabled"
        });
        _dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_old_disabled",
            UserId = "former-user-disabled",
            Status = StripeSubscriptionStatus.CANCELED,
            Created = new DateTime(2025, 4, 1, 12, 0, 0, DateTimeKind.Utc),
            NextChargeDate = null,
        });
        _dbContext.SetFormerSubscriberExtraMonths(0);
        _dbContext.SaveChanges();

        var session = new Stripe.Checkout.Session
        {
            Id = "cs_former_disabled",
            CustomerId = "cus_former_disabled",
            SubscriptionId = "sub_new_disabled"
        };

        _stripeGateway.GetCheckoutSession("cs_former_disabled").Returns(session);
        _stripeGateway.GetSubscription("sub_new_disabled").Returns(CreateStripeSubscription(
            id: "sub_new_disabled",
            status: "active",
            currentPeriodEnd: new DateTime(2027, 4, 12, 12, 0, 0, DateTimeKind.Utc)));

        _stripeService.FulfillCheckoutSession("cs_former_disabled");

        _stripeGateway.DidNotReceive().UpdateSubscriptionTrialEnd(Arg.Any<string>(), Arg.Any<DateTime>());
        _dbContext.StripeSubscriptions.Should().ContainSingle(subscription =>
            subscription.SubscriptionId == "sub_new_disabled" &&
            subscription.Status == StripeSubscriptionStatus.ACTIVE &&
            subscription.NextChargeDate == new DateOnly(2027, 4, 12));
    }

    [Fact]
    public void ToStripeSubscriptionStatus_should_map_active_subscription_scheduled_for_cancellation_to_unsubscribed()
    {
        var subscription = CreateStripeSubscription(status: "active", cancelAtPeriodEnd: true);

        var status = subscription.ToStripeSubscriptionStatus();

        status.Should().Be(StripeSubscriptionStatus.UNSUBSCRIBED);
    }

    [Fact]
    public void ToStripeSubscriptionStatus_should_map_canceled_subscription_even_when_cancel_at_period_end_is_true()
    {
        var subscription = CreateStripeSubscription(status: "canceled", cancelAtPeriodEnd: true);

        var status = subscription.ToStripeSubscriptionStatus();

        status.Should().Be(StripeSubscriptionStatus.CANCELED);
    }

    [Fact]
    public void ToStripeSubscriptionStatus_should_map_active_subscription_with_cancel_at_to_unsubscribed()
    {
        var subscription = CreateStripeSubscription(status: "active", cancelAt: DateTime.UtcNow.AddDays(30));

        var status = subscription.ToStripeSubscriptionStatus();

        status.Should().Be(StripeSubscriptionStatus.UNSUBSCRIBED);
    }

    private static Subscription CreateStripeSubscription(
        string id = "sub_123",
        string status = "active",
        bool cancelAtPeriodEnd = false,
        DateTime? cancelAt = null,
        DateTime? currentPeriodEnd = null)
    {
        return new Subscription
        {
            Id = id,
            Status = status,
            CancelAtPeriodEnd = cancelAtPeriodEnd,
            CancelAt = cancelAt,
            Items = new StripeList<SubscriptionItem>
            {
                Data =
                [
                    new SubscriptionItem
                    {
                        CurrentPeriodEnd = currentPeriodEnd ?? new DateTime(2026, 4, 24, 0, 0, 0, DateTimeKind.Utc)
                    }
                ]
            }
        };
    }
}
