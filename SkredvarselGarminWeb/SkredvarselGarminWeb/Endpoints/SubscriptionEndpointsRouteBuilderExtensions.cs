using Hangfire;
using Refit;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;
using AgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;

namespace SkredvarselGarminWeb.Endpoints;

public static class SubscriptionEndpointsRouteBuilderExtensions
{
    private const int CampaignPrice = 100;
    private const int FullPrice = 3000;

    public static void MapSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/createSubscription", async (
            HttpContext ctx,
            IVippsApiClient vippsApiClient,
            SkredvarselDbContext dbContext,
            IDateTimeNowProvider dateTimeNowProvider) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var userId = user.Id;
            var userPhoneNumber = user.PhoneNumber;

            var existingAgreementsForUser = dbContext.Agreements
                .Where(a => a.UserId == userId)
                .ToList();

            var isNewCustomer = !existingAgreementsForUser.Any();

            var baseUrl = $"{ctx.Request.Scheme}://{ctx.Request.Host}";

            if (existingAgreementsForUser.Any(x => x.Status == AgreementStatus.ACTIVE))
            {
                return Results.Redirect($"{baseUrl}/minSide");
            }

            var pendingAgreementForUser = existingAgreementsForUser.FirstOrDefault(x => x.Status == AgreementStatus.PENDING);
            if (pendingAgreementForUser != null && pendingAgreementForUser.ConfirmationUrl != null)
            {
                return Results.Redirect(pendingAgreementForUser.ConfirmationUrl);
            }

            var request = new DraftAgreementRequest
            {
                CustomerPhoneNumber = userPhoneNumber,
                Pricing = new()
                {
                    Amount = FullPrice,
                },
                Interval = new()
                {
                    Count = 1,
                    Unit = PeriodUnit.Year
                },
                Campaign = isNewCustomer ? new()
                {
                    Price = CampaignPrice,
                    Type = CampaignType.PeriodCampaign,
                    Period = new()
                    {
                        Count = 1,
                        Unit = PeriodUnit.Month
                    }
                } : null,
                InitialCharge = isNewCustomer ? new()
                {
                    Amount = 100,
                    Description = "Første måned"
                } : new()
                {
                    Amount = FullPrice,
                    Description = "Skredvarsel for Garmin"
                },
                ProductName = "Skredvarsel for Garmin",
                MerchantAgreementUrl = $"https://skredvarsel.app/minSide",
                MerchantRedirectUrl = $"{baseUrl}/vipps-subscribe-callback"
            };

            try
            {
                var createdAgreement = await vippsApiClient.CreateAgreement(request, Guid.NewGuid());

                dbContext.Add(new Entities.Agreement
                {
                    Id = createdAgreement.AgreementId,
                    Created = dateTimeNowProvider.Now.ToUniversalTime(),
                    UserId = userId,
                    Status = AgreementStatus.PENDING,
                    ConfirmationUrl = createdAgreement.VippsConfirmationUrl,
                    Start = DateOnly.FromDateTime(DateTime.Now),
                    NextChargeId = createdAgreement.ChargeId,
                    NextChargeDate = DateOnly.FromDateTime(DateTime.Now)
                });
                dbContext.SaveChanges();

                return Results.Redirect(createdAgreement.VippsConfirmationUrl);
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        }).RequireAuthorization();

        app.MapGet("/vipps-subscribe-callback", async (
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IVippsApiClient vippsApiClient,
            ISubscriptionService subscriptionService,
            IBackgroundJobClient backgroundJobClient,
            IDateTimeNowProvider dateTimeNowProvider) =>
        {
            var pendingAgreements = dbContext.GetPendingAgreements();
            foreach (var agreement in pendingAgreements)
            {
                var agreementInVipps = await vippsApiClient.GetAgreement(agreement.Id);

                if (agreementInVipps.Status == VippsAgreementStatus.Stopped)
                {
                    dbContext.Remove(agreement);
                }
                else if (agreementInVipps.Status == VippsAgreementStatus.Active)
                {
                    agreement.SetAsActive();
                    backgroundJobClient.Enqueue(() => subscriptionService.UpdateAgreementCharges(agreement.Id));
                }
            }

            dbContext.SaveChanges();

            return Results.Redirect("/minSide?subscribed");
        });

        app.MapGet("/api/subscription", async (
            HttpContext ctx,
            IVippsApiClient vippsApiClient,
            ISubscriptionService subscriptionService,
            IBackgroundJobClient backgroundJobClient,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var agreementsInDb = dbContext.Agreements
                .OrderByDescending(a => a.Created)
                .Where(a => a.UserId == user.Id)
                .ToList();

            if (agreementsInDb.Any())
            {
                var activeAgreement = agreementsInDb.FirstOrDefault(a => a.Status == AgreementStatus.ACTIVE || a.Status == AgreementStatus.UNSUBSCRIBED);
                if (activeAgreement != null)
                {
                    return Results.Ok(new Subscription
                    {
                        Status = activeAgreement.Status,
                        NextChargeDate = activeAgreement.NextChargeDate,
                    });
                }

                var pendingAgreement = agreementsInDb.FirstOrDefault(a => a.Status == AgreementStatus.PENDING);
                if (pendingAgreement != null)
                {
                    var agreementInVipps = await vippsApiClient.GetAgreement(pendingAgreement.Id);

                    if (agreementInVipps.Status == VippsAgreementStatus.Active)
                    {
                        pendingAgreement.SetAsActive();
                        dbContext.SaveChanges();

                        backgroundJobClient.Enqueue(() => subscriptionService.UpdateAgreementCharges(pendingAgreement.Id));
                    }

                    return Results.Ok(new Subscription
                    {
                        Status = pendingAgreement.Status,
                        NextChargeDate = pendingAgreement.NextChargeDate,
                        VippsConfirmationUrl = pendingAgreement.ConfirmationUrl
                    });
                }
            }

            return Results.NoContent();
        }).RequireAuthorization();

        app.MapDelete("/api/subscription", async (
            HttpContext ctx,
            ISubscriptionService subscriptionService,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var agreementInDb = dbContext.Agreements
                .Where(a => a.Status == AgreementStatus.ACTIVE)
                .FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb == null)
            {
                return Results.BadRequest("No subscription found.");
            }

            await subscriptionService.DeactivateAgreement(agreementInDb.Id);

            return Results.Ok();

        }).RequireAuthorization();

        app.MapPut("/api/subscription/reactivate", async (
            HttpContext ctx,
            ISubscriptionService subscriptionService,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var agreementInDb = dbContext.Agreements
                .Where(a => a.Status == AgreementStatus.UNSUBSCRIBED)
                .FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb == null)
            {
                return Results.BadRequest("No subscription found.");
            }

            await subscriptionService.ReactivateAgreement(agreementInDb.Id);

            return Results.Ok();
        }).RequireAuthorization();
    }
}
