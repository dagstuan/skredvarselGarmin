using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Endpoints;

public static class AdminEndpointsRouteBuilderExtensions
{
    public static void MapAdminEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/admin", (SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider) =>
        {
            var staleUsers = dbContext.GetUsersNotLoggedInForAMonthWithoutAgreements(dateTimeNowProvider);

            var numUsers = dbContext.Users.Count();
            var activeAgreements = dbContext.Agreements.Count(a => a.Status == Entities.AgreementStatus.ACTIVE);
            var activeStripeSubscriptions = dbContext.StripeSubscriptions.Count(ss => ss.Status == Entities.StripeSubscriptionStatus.ACTIVE);
            var unsubscribedAgreements = dbContext.Agreements.Count(a => a.Status == Entities.AgreementStatus.UNSUBSCRIBED);
            var unsubscribedStripeSubscriptions = dbContext.StripeSubscriptions.Count(a => a.Status == Entities.StripeSubscriptionStatus.UNSUBSCRIBED);
            var watches = dbContext.Watches.Count();

            var totalActiveAgreements = activeAgreements + activeStripeSubscriptions;
            var totalUnsubscribedAgreements = unsubscribedAgreements + unsubscribedStripeSubscriptions;

            return new AdminData
            {
                StaleUsers = [.. staleUsers.Select(u => new AdminDataUser
                {
                    Id = u.Id,
                    Name = u.Name
                })],
                NumUsers = numUsers,
                ActiveAgreements = totalActiveAgreements,
                UnsubscribedAgreements = totalUnsubscribedAgreements,
                ActiveOrUnsubscribedAgreements = totalActiveAgreements + totalUnsubscribedAgreements,
                Watches = watches
            };
        }).RequireAuthorization("Admin");
    }
}
