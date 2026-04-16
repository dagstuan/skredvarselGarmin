using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;

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
            var activeStripeSubscriptions = dbContext.StripeSubscriptions.WhereActive().Count();
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

        app.MapGet("/api/admin/agreements", (SkredvarselDbContext dbContext) =>
        {
            return dbContext.Agreements.ToList();
        }).RequireAuthorization("Admin");

        app.MapGet("/api/admin/agreements/due-in-less-than-30-days", (SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider) =>
        {
            return dbContext.GetAgreementsDueInLessThan30Days(dateTimeNowProvider).ToList();
        }).RequireAuthorization("Admin");

        app.MapGet("/api/admin/agreements/due-in-less-than-30-days-without-next-charge-id", (SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider) =>
        {
            return dbContext.GetActiveAgreementsDueInLessThan30DaysWithoutNextChargeId(dateTimeNowProvider).ToList();
        }).RequireAuthorization("Admin");

        app.MapGet("/api/admin/users/former-subscribers", (SkredvarselDbContext dbContext) =>
        {
            var formerSubscribers = dbContext.GetFormerSubscribers();

            return formerSubscribers.Select(u => new FormerSubscriberAdminUser
            {
                Id = u.Id,
                Name = u.Name,
                Email = u.Email,
                LastLoggedIn = u.LastLoggedIn,
            }).ToList();
        }).RequireAuthorization("Admin");

        app.MapGet("/api/admin/subscription-settings", (SkredvarselDbContext dbContext) =>
        {
            return dbContext.GetSubscriptionSettings();
        }).RequireAuthorization("Admin");

        app.MapPut("/api/admin/subscription-settings/former-subscriber-extra-months", (SubscriptionSettings request, SkredvarselDbContext dbContext) =>
        {
            if (request.FormerSubscriberExtraMonths < 0)
            {
                return Results.BadRequest("Extra months must be 0 or greater.");
            }

            var settings = dbContext.SetFormerSubscriberExtraMonths(request.FormerSubscriberExtraMonths);
            dbContext.SaveChanges();

            return Results.Ok(settings);
        }).RequireAuthorization("Admin");

        app.MapGet("/api/admin/agreements/{agreementId}", (string agreementId, SkredvarselDbContext dbContext) =>
        {
            return dbContext.Agreements.Single(a => a.Id == agreementId);
        }).RequireAuthorization("Admin");

        app.MapPost("/api/admin/agreements/{agreementId}/create-next-charge", async (string agreementId, IVippsAgreementService subscriptionService) =>
        {
            await subscriptionService.CreateNextChargeForAgreement(agreementId);
        }).RequireAuthorization("Admin");

        app.MapPost("/api/admin/agreements/{agreementId}/update-agreement-charges", async (string agreementId, IVippsAgreementService subscriptionService) =>
        {
            await subscriptionService.UpdateAgreementCharges(agreementId);
        }).RequireAuthorization("Admin");
    }
}
