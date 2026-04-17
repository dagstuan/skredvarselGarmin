using Microsoft.Extensions.Options;

using Resend;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Options;

namespace SkredvarselGarminWeb.Services;

public class ResendAudienceSyncService(
    SkredvarselDbContext dbContext,
    IResend resend,
    IOptions<ResendOptions> resendOptions,
    ILogger<ResendAudienceSyncService> logger) : IResendAudienceSyncService
{
    private const string LocalUserIdPropertyKey = "skredvarsel_user_id";
    private const string UserStatusPropertyKey = "skredvarsel_user_status";
    private const string FormerSubscriberStatusValue = "former_subscriber";
    private const string LocalUserStatusValue = "local_user";

    public async Task SyncUsers(CancellationToken cancellationToken = default)
    {
        if (!resendOptions.Value.EnableAudienceSync)
        {
            logger.LogInformation("Skipping Resend audience sync because it is disabled in configuration.");
            return;
        }

        if (string.IsNullOrWhiteSpace(resendOptions.Value.ApiToken))
        {
            logger.LogWarning("Skipping Resend audience sync because the Resend API token is not configured.");
            return;
        }

        await EnsureContactPropertyExists(LocalUserIdPropertyKey, cancellationToken);
        await EnsureContactPropertyExists(UserStatusPropertyKey, cancellationToken);

        var formerSubscribersSegmentId = await GetOrCreateFormerSubscribersSegment(cancellationToken);
        var localUsers = dbContext.Users.ToList();
        var formerSubscriberIds = dbContext.GetFormerSubscribers()
            .Select(user => user.Id)
            .ToHashSet(StringComparer.Ordinal);

        var contacts = await ListAllContacts(cancellationToken);
        var retainedContactIds = new HashSet<Guid>();

        var createdContacts = 0;
        var updatedContacts = 0;
        var addedToFormerSegment = 0;
        var removedFromFormerSegment = 0;
        var prunedContacts = 0;
        var failedUsers = 0;

        foreach (var user in localUsers)
        {
            cancellationToken.ThrowIfCancellationRequested();

            try
            {
                var existingContact = SelectExistingContact(contacts, user.Email);
                var isFormerSubscriber = formerSubscriberIds.Contains(user.Id);
                var contactData = BuildContactData(user, isFormerSubscriber);

                Guid contactId;

                if (existingContact == null)
                {
                    contactId = await RequireSuccess(
                        resend.ContactAddAsync(contactData, cancellationToken),
                        $"creating contact for '{user.Email}'");
                    createdContacts++;
                }
                else
                {
                    await RequireSuccess(
                        resend.ContactUpdateAsync(existingContact.Id, contactData, cancellationToken),
                        $"updating contact '{existingContact.Id}'");
                    contactId = existingContact.Id;
                    updatedContacts++;
                }

                retainedContactIds.Add(contactId);

                var segmentIds = await ListAllContactSegmentIds(contactId, cancellationToken);
                var isInFormerSubscribersSegment = segmentIds.Contains(formerSubscribersSegmentId);

                if (isFormerSubscriber && !isInFormerSubscribersSegment)
                {
                    await RequireSuccess(
                        resend.ContactAddToSegmentAsync(contactId, formerSubscribersSegmentId, cancellationToken),
                        $"adding contact '{contactId}' to the former subscribers segment");
                    addedToFormerSegment++;
                }
                else if (!isFormerSubscriber && isInFormerSubscribersSegment)
                {
                    await RequireSuccess(
                        resend.ContactRemoveFromSegmentAsync(contactId, formerSubscribersSegmentId, cancellationToken),
                        $"removing contact '{contactId}' from the former subscribers segment");
                    removedFromFormerSegment++;
                }
            }
            catch (Exception exception)
            {
                failedUsers++;
                logger.LogError(exception, "Failed syncing Resend contact for local user {userId} ({email}).", user.Id, user.Email);
            }
        }

        foreach (var contact in contacts.Where(contact => !retainedContactIds.Contains(contact.Id)))
        {
            cancellationToken.ThrowIfCancellationRequested();

            try
            {
                await RequireSuccess(
                    resend.ContactDeleteAsync(contact.Id, cancellationToken),
                    $"deleting stale Resend contact '{contact.Id}'");
                prunedContacts++;
            }
            catch (Exception exception)
            {
                logger.LogError(exception, "Failed pruning stale Resend contact {contactId} ({email}).", contact.Id, contact.Email);
            }
        }

        logger.LogInformation(
            "Finished syncing Resend audience. Created {createdContacts} contacts, updated {updatedContacts}, added {addedToFormerSegment} contacts to the former subscribers segment, removed {removedFromFormerSegment} contacts from the former subscribers segment, pruned {prunedContacts} stale contacts, and had {failedUsers} per-user failures.",
            createdContacts,
            updatedContacts,
            addedToFormerSegment,
            removedFromFormerSegment,
            prunedContacts,
            failedUsers);
    }

    private async Task EnsureContactPropertyExists(string propertyKey, CancellationToken cancellationToken)
    {
        var properties = await ListAllContactProperties(cancellationToken);

        if (properties.Any(property => string.Equals(property.Key, propertyKey, StringComparison.OrdinalIgnoreCase)))
        {
            return;
        }

        await RequireSuccess(
            resend.ContactPropCreateAsync(new ContactPropertyData
            {
                Key = propertyKey,
                PropertyType = ContactPropertyType.String,
            }, cancellationToken),
            $"creating contact property '{propertyKey}'");
    }

    private async Task<Guid> GetOrCreateFormerSubscribersSegment(CancellationToken cancellationToken)
    {
        var existingSegment = (await ListAllSegments(cancellationToken))
            .FirstOrDefault(segment => string.Equals(segment.Name, resendOptions.Value.FormerSubscribersSegmentName, StringComparison.Ordinal));

        if (existingSegment != null)
        {
            return existingSegment.Id;
        }

        return await RequireSuccess(
            resend.SegmentCreateAsync(new SegmentData
            {
                Name = resendOptions.Value.FormerSubscribersSegmentName,
            }, cancellationToken),
            $"creating segment '{resendOptions.Value.FormerSubscribersSegmentName}'");
    }

    private async Task<List<Contact>> ListAllContacts(CancellationToken cancellationToken)
    {
        return await ListAllPages(
            query => resend.ContactListAsync(query, cancellationToken),
            contact => contact.Id.ToString(),
            "listing contacts",
            cancellationToken);
    }

    private async Task<List<Segment>> ListAllSegments(CancellationToken cancellationToken)
    {
        return await ListAllPages(
            query => resend.SegmentListAsync(query, cancellationToken),
            segment => segment.Id.ToString(),
            "listing segments",
            cancellationToken);
    }

    private async Task<List<ContactProperty>> ListAllContactProperties(CancellationToken cancellationToken)
    {
        return await ListAllPages(
            query => resend.ContactPropListAsync(query, cancellationToken),
            property => property.Id.ToString(),
            "listing contact properties",
            cancellationToken);
    }

    private async Task<HashSet<Guid>> ListAllContactSegmentIds(Guid contactId, CancellationToken cancellationToken)
    {
        var segments = await ListAllPages(
            query => resend.ContactListSegmentsAsync(contactId, query, cancellationToken),
            segment => segment.Id.ToString(),
            $"listing segments for contact '{contactId}'",
            cancellationToken);

        return segments.Select(segment => segment.Id).ToHashSet();
    }

    private static async Task<List<T>> ListAllPages<T>(
        Func<PaginatedQuery, Task<ResendResponse<PaginatedResult<T>>>> fetchPage,
        Func<T, string> cursorSelector,
        string operation,
        CancellationToken cancellationToken)
    {
        var results = new List<T>();
        string? after = null;

        while (true)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var page = await RequireSuccess(
                fetchPage(new PaginatedQuery
                {
                    Limit = 100,
                    After = after,
                }),
                operation);

            results.AddRange(page.Data);

            if (!page.HasMore || page.Data.Count == 0)
            {
                return results;
            }

            after = cursorSelector(page.Data[^1]);
        }
    }

    private static Contact? SelectExistingContact(IEnumerable<Contact> contacts, string email)
    {
        return contacts
            .FirstOrDefault(contact => string.Equals(contact.Email, email, StringComparison.OrdinalIgnoreCase));
    }

    private static ContactData BuildContactData(User user, bool isFormerSubscriber)
    {
        return new ContactData
        {
            Email = user.Email,
            Properties = new Dictionary<string, string>
            {
                [LocalUserIdPropertyKey] = user.Id,
                [UserStatusPropertyKey] = isFormerSubscriber
                    ? FormerSubscriberStatusValue
                    : LocalUserStatusValue,
            }
        };
    }

    private static async Task RequireSuccess(Task<ResendResponse> responseTask, string operation)
    {
        var response = await responseTask;

        if (response.Success)
        {
            return;
        }

        if (response.Exception != null)
        {
            throw response.Exception;
        }

        throw new InvalidOperationException($"Resend operation failed: {operation}.");
    }

    private static async Task<T> RequireSuccess<T>(Task<ResendResponse<T>> responseTask, string operation)
    {
        var response = await responseTask;

        if (response.Success)
        {
            return response.Content;
        }

        if (response.Exception != null)
        {
            throw response.Exception;
        }

        throw new InvalidOperationException($"Resend operation failed: {operation}.");
    }
}
