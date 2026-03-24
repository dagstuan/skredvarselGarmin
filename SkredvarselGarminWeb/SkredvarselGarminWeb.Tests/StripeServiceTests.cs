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

        _stripeService = new StripeService(
            _dbContext,
            Substitute.For<IStripeClient>(),
            Substitute.For<INotificationService>(),
            Substitute.For<IDateTimeNowProvider>(),
            Substitute.For<ILogger<StripeService>>());
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
