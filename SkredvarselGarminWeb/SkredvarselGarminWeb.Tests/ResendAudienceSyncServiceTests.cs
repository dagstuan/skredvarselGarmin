using AwesomeAssertions;

using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

using NSubstitute;

using Resend;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Tests;

public class ResendAudienceSyncServiceTests
{
    [Fact]
    public async Task SyncUsers_should_sync_contacts_manage_former_subscriber_membership_and_prune_stale_contacts()
    {
        using var dbContext = CreateDbContext();

        var currentUser = CreateUser("current-user", "current.user@example.com", "Current User");
        var formerUser = CreateUser("former-user", "former.user@example.com", "Former User");

        dbContext.Users.AddRange(currentUser, formerUser);
        dbContext.Agreements.Add(new Agreement
        {
            Id = "agreement-stopped",
            CallbackId = null,
            WatchKey = null,
            Created = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = AgreementStatus.STOPPED,
            Start = new DateOnly(2025, 12, 10),
            NextChargeDate = null,
            UserId = formerUser.Id,
        });
        dbContext.SaveChanges();

        var resend = Substitute.For<IResend>();
        var logger = Substitute.For<ILogger<ResendAudienceSyncService>>();
        var formerSubscribersSegmentId = Guid.NewGuid();
        var currentContactId = Guid.NewGuid();
        var formerContactId = Guid.NewGuid();
        var staleContactId = Guid.NewGuid();
        var additionalStaleContactId = Guid.NewGuid();

        resend.ContactPropListAsync(Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<ContactProperty>
            {
                HasMore = false,
                Data =
                [
                    new ContactProperty { Id = Guid.NewGuid(), Key = "skredvarsel_user_id", PropertyType = ContactPropertyType.String, MomentCreated = DateTime.UtcNow },
                    new ContactProperty { Id = Guid.NewGuid(), Key = "skredvarsel_user_status", PropertyType = ContactPropertyType.String, MomentCreated = DateTime.UtcNow },
                ],
            })));
        resend.SegmentListAsync(Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Segment>
            {
                HasMore = false,
                Data =
                [
                    new Segment { Id = formerSubscribersSegmentId, Name = "Former Subscribers", MomentCreated = DateTime.UtcNow },
                ],
            })));
        resend.ContactListAsync(Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Contact>
            {
                HasMore = false,
                Data =
                [
                    new Contact
                    {
                        Id = currentContactId,
                        Email = currentUser.Email,
                        FirstName = "Current",
                        LastName = "User",
                        MomentCreated = DateTime.UtcNow,
                        Properties = new Dictionary<string, string>
                        {
                            ["skredvarsel_user_id"] = currentUser.Id,
                            ["skredvarsel_user_status"] = "former_subscriber",
                        },
                    },
                    new Contact
                    {
                        Id = staleContactId,
                        Email = "stale.user@example.com",
                        MomentCreated = DateTime.UtcNow,
                        Properties = new Dictionary<string, string>
                        {
                            ["skredvarsel_user_id"] = "deleted-user",
                            ["skredvarsel_user_status"] = "local_user",
                        },
                    },
                    new Contact
                    {
                        Id = additionalStaleContactId,
                        Email = "external.user@example.com",
                        MomentCreated = DateTime.UtcNow,
                    },
                ],
            })));
        resend.ContactUpdateAsync(currentContactId, Arg.Any<ContactData>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success()));
        resend.ContactAddAsync(Arg.Any<ContactData>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(formerContactId)));
        resend.ContactListSegmentsAsync(currentContactId, Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Segment>
            {
                HasMore = false,
                Data =
                [
                    new Segment { Id = formerSubscribersSegmentId, Name = "Former Subscribers", MomentCreated = DateTime.UtcNow },
                ],
            })));
        resend.ContactListSegmentsAsync(formerContactId, Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Segment>
            {
                HasMore = false,
                Data = [],
            })));
        resend.ContactRemoveFromSegmentAsync(currentContactId, formerSubscribersSegmentId, Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success()));
        resend.ContactAddToSegmentAsync(formerContactId, formerSubscribersSegmentId, Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success()));
        resend.ContactDeleteAsync(staleContactId, Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success()));
        resend.ContactDeleteAsync(additionalStaleContactId, Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success()));

        var service = CreateService(dbContext, resend, logger);

        await service.SyncUsers();

        await resend.Received(1).ContactUpdateAsync(
            currentContactId,
            Arg.Is<ContactData>(data =>
                data.Email == currentUser.Email &&
                data.Properties != null &&
                data.Properties["skredvarsel_user_id"] == currentUser.Id &&
                data.Properties["skredvarsel_user_status"] == "local_user"),
            Arg.Any<CancellationToken>());
        await resend.Received(1).ContactAddAsync(
            Arg.Is<ContactData>(data =>
                data.Email == formerUser.Email &&
                data.Properties != null &&
                data.Properties["skredvarsel_user_id"] == formerUser.Id &&
                data.Properties["skredvarsel_user_status"] == "former_subscriber"),
            Arg.Any<CancellationToken>());
        await resend.Received(1).ContactRemoveFromSegmentAsync(currentContactId, formerSubscribersSegmentId, Arg.Any<CancellationToken>());
        await resend.Received(1).ContactAddToSegmentAsync(formerContactId, formerSubscribersSegmentId, Arg.Any<CancellationToken>());
        await resend.Received(1).ContactDeleteAsync(staleContactId, Arg.Any<CancellationToken>());
        await resend.Received(1).ContactDeleteAsync(additionalStaleContactId, Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task SyncUsers_should_create_missing_contact_properties_and_former_subscribers_segment()
    {
        using var dbContext = CreateDbContext();

        var formerUser = CreateUser("former-user", "former.user@example.com", "Former User");
        dbContext.Users.Add(formerUser);
        dbContext.StripeSubscriptions.Add(new StripeSubscription
        {
            SubscriptionId = "sub_canceled",
            Created = new DateTime(2026, 2, 10, 0, 0, 0, DateTimeKind.Utc),
            Status = StripeSubscriptionStatus.CANCELED,
            NextChargeDate = null,
            UserId = formerUser.Id,
        });
        dbContext.SaveChanges();

        var resend = Substitute.For<IResend>();
        var logger = Substitute.For<ILogger<ResendAudienceSyncService>>();
        var formerSubscribersSegmentId = Guid.NewGuid();
        var formerContactId = Guid.NewGuid();

        resend.ContactPropListAsync(Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<ContactProperty>
            {
                HasMore = false,
                Data = [],
            })));
        resend.ContactPropCreateAsync(Arg.Any<ContactPropertyData>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(Guid.NewGuid())));
        resend.SegmentListAsync(Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Segment>
            {
                HasMore = false,
                Data = [],
            })));
        resend.SegmentCreateAsync(Arg.Any<SegmentData>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(formerSubscribersSegmentId)));
        resend.ContactListAsync(Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Contact>
            {
                HasMore = false,
                Data = [],
            })));
        resend.ContactAddAsync(Arg.Any<ContactData>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(formerContactId)));
        resend.ContactListSegmentsAsync(formerContactId, Arg.Any<PaginatedQuery>(), Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success(new PaginatedResult<Segment>
            {
                HasMore = false,
                Data = [],
            })));
        resend.ContactAddToSegmentAsync(formerContactId, formerSubscribersSegmentId, Arg.Any<CancellationToken>())
            .Returns(Task.FromResult(Success()));

        var service = CreateService(
            dbContext,
            resend,
            logger,
            new ResendOptions
            {
                ApiToken = "test-token",
                FormerSubscribersSegmentName = "Skredvarsel Former Subscribers",
            });

        await service.SyncUsers();

        await resend.Received(1).ContactPropCreateAsync(
            Arg.Is<ContactPropertyData>(data => data.Key == "skredvarsel_user_id" && data.PropertyType == ContactPropertyType.String),
            Arg.Any<CancellationToken>());
        await resend.Received(1).ContactPropCreateAsync(
            Arg.Is<ContactPropertyData>(data => data.Key == "skredvarsel_user_status" && data.PropertyType == ContactPropertyType.String),
            Arg.Any<CancellationToken>());
        await resend.Received(1).SegmentCreateAsync(
            Arg.Is<SegmentData>(data => data.Name == "Skredvarsel Former Subscribers"),
            Arg.Any<CancellationToken>());
        await resend.Received(1).ContactAddToSegmentAsync(formerContactId, formerSubscribersSegmentId, Arg.Any<CancellationToken>());
    }

    private static ResendAudienceSyncService CreateService(
        SkredvarselDbContext dbContext,
        IResend resend,
        ILogger<ResendAudienceSyncService> logger,
        ResendOptions? options = null)
    {
        return new ResendAudienceSyncService(
            dbContext,
            resend,
            Microsoft.Extensions.Options.Options.Create(options ?? new ResendOptions { ApiToken = "test-token" }),
            logger);
    }

    private static SkredvarselDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new SkredvarselDbContext(options);
    }

    private static User CreateUser(string id, string email, string name)
    {
        return new User
        {
            Id = id,
            Email = email,
            Name = name,
            LastLoggedIn = new DateOnly(2026, 3, 15),
            CreatedDate = new DateOnly(2026, 1, 10),
            Agreements = [],
            Watches = [],
            StripeSubscriptions = [],
        };
    }

    private static ResendResponse Success()
    {
        return new ResendResponse(null);
    }

    private static ResendResponse<T> Success<T>(T value)
    {
        return new ResendResponse<T>(value, null);
    }
}
