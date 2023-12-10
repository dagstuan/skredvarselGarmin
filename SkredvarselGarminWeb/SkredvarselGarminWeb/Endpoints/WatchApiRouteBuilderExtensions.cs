using System.Net;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Helpers;
using WatchEntityModel = SkredvarselGarminWeb.Entities.Watch;

namespace SkredvarselGarminWeb.Endpoints;

public static class WatchApiRouteBuilderExtensions
{
    public static void MapWatchApiEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/watch/setupSubscription", (
            HttpContext ctx,
            SetupSubscriptionRequest request,
            SkredvarselDbContext dbContext,
            IDateTimeNowProvider dateTimeNowProvider) =>
        {
            var existingWatch = dbContext.Watches.FirstOrDefault(w => w.Id == request.WatchId);

            if (existingWatch != null)
            {
                var doesUserHaveActiveAgreement = dbContext.DoesUserHaveActiveAgreement(existingWatch.UserId);

                return Results.Ok(new SetupSubscriptionResponse
                {
                    Status = doesUserHaveActiveAgreement ?
                        SetupSubscriptionStatus.SEEN_WATCH_ACTIVE_SUBSCRIPTION :
                        SetupSubscriptionStatus.SEEN_WATCH_INACTIVE_SUBSCRIPTION,
                });
            }

            var existingRequest = dbContext.WatchAddRequests.FirstOrDefault(r => r.WatchId == request.WatchId);

            if (existingRequest != null)
            {
                return Results.Ok(new SetupSubscriptionResponse
                {
                    Status = SetupSubscriptionStatus.NEW_WATCH,
                    AddWatchKey = existingRequest.Key
                });
            }

            var key = GenerateKey();
            dbContext.WatchAddRequests.Add(new WatchAddRequest
            {
                Created = dateTimeNowProvider.Now.SetKindUtc(),
                PartNumber = request.PartNumber,
                Key = key,
                WatchId = request.WatchId
            });
            dbContext.SaveChanges();

            return Results.Ok(new SetupSubscriptionResponse
            {
                Status = SetupSubscriptionStatus.NEW_WATCH,
                AddWatchKey = key
            });
        });

        app.MapGet("/api/watch/checkSubscription", () => Results.Ok()).RequireAuthorization("Garmin");

        app.MapGet("/api/watches", (HttpContext ctx, SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var watches = dbContext.Watches.Where(w => w.UserId == user.Id);

            return watches.Select(w => w.ToEndpointModel());
        }).RequireAuthorization();

        app.MapPost("/api/watches/{watchAddKey}", (HttpContext ctx, string watchAddKey, SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var watchAddRequest = dbContext.WatchAddRequests.FirstOrDefault(r => r.Key == watchAddKey);

            if (watchAddRequest == null)
            {
                return Results.Problem("Fant ikke noen klokke med den koden.", statusCode: (int)HttpStatusCode.BadRequest);
            }

            dbContext.Remove(watchAddRequest);
            dbContext.Add(new WatchEntityModel
            {
                Id = watchAddRequest.WatchId,
                PartNumber = watchAddRequest.PartNumber,
                UserId = user.Id
            });
            dbContext.SaveChanges();

            return Results.Ok();
        }).RequireAuthorization();

        app.MapDelete("/api/watches/{watchId}", (HttpContext ctx, SkredvarselDbContext dbContext, string watchId) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var watch = dbContext.Watches.FirstOrDefault(w => w.Id == watchId && w.UserId == user.Id);

            if (watch != null)
            {
                dbContext.Remove(watch);
                dbContext.SaveChanges();

                return Results.Ok();
            }

            return Results.BadRequest();
        }).RequireAuthorization();
    }

    private static string GenerateKey()
    {
        var random = new Random();
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

        return new string(Enumerable.Repeat(chars, 4)
        .Select(s => s[random.Next(s.Length)]).ToArray());
    }
}
