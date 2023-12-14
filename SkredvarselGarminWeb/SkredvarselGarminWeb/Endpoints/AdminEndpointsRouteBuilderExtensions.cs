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
            var unsubscribedAgreements = dbContext.Agreements.Count(a => a.Status == Entities.AgreementStatus.UNSUBSCRIBED);
            var watches = dbContext.Watches.Count();

            return new AdminData
            {
                StaleUsers = [.. staleUsers.Select(u => new AdminDataUser
                {
                    Id = u.Id,
                    Name = u.Name
                })],
                NumUsers = numUsers,
                ActiveAgreements = activeAgreements,
                UnsubscribedAgreements = unsubscribedAgreements,
                ActiveOrUnsubscribedAgreements = activeAgreements + unsubscribedAgreements,
                Watches = watches
            };
        }).RequireAuthorization("Admin");
    }
}
