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
    public void StoreNewSubscriptionIfNotExists_should_not_create_duplicate_subscription()
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

        _stripeService.StoreNewSubscriptionIfNotExists(session);

        _dbContext.StripeSubscriptions.Should().ContainSingle(subscription => subscription.SubscriptionId == "sub_existing");
        _stripeGateway.DidNotReceive().GetSubscription(Arg.Any<string>());
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
