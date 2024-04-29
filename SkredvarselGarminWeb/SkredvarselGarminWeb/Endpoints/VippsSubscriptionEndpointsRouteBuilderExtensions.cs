using Hangfire;

using Refit;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

using AgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;


namespace SkredvarselGarminWeb.Endpoints;

public static class VippsSubscriptionEndpointsRouteBuilderExtensions
{
    private const int CampaignPrice = 100;
    private const int FullPrice = 3000;

    public static void MapVippsSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/createVippsAgreement", async (
            HttpContext ctx,
            IVippsApiClient vippsApiClient,
            IUserService userService,
            SkredvarselDbContext dbContext,
            IDateTimeNowProvider dateTimeNowProvider) =>
        {
            var user = await userService.GetUserOrRegisterLogin(ctx.User);

            var userId = user.Id;

            var existingAgreementsForUser = dbContext.Agreements
                .Where(a => a.UserId == userId)
                .ToList();

            var isNewCustomer = existingAgreementsForUser.Count == 0;

            var baseUrl = ctx.GetBaseUrl();

            if (existingAgreementsForUser.Any(x => x.Status == AgreementStatus.ACTIVE))
            {
                return Results.Redirect($"{baseUrl}/account");
            }

            var pendingAgreementForUser = existingAgreementsForUser.FirstOrDefault(x => x.Status == AgreementStatus.PENDING);
            if (pendingAgreementForUser != null && pendingAgreementForUser.ConfirmationUrl != null)
            {
                return Results.Redirect(pendingAgreementForUser.ConfirmationUrl);
            }

            var request = new DraftAgreementRequest
            {
                CustomerPhoneNumber = ctx.User.Claims.GetClaimValueOrNull("phone_number"),
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
                        Unit = PeriodUnit.Week
                    }
                } : null,
                InitialCharge = isNewCustomer ? new()
                {
                    Amount = 100,
                    Description = "Første uke"
                } : new()
                {
                    Amount = FullPrice,
                    Description = "Skredvarsel for Garmin"
                },
                ProductName = "Skredvarsel for Garmin",
                MerchantAgreementUrl = $"{baseUrl}/account",
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
            IVippsAgreementService subscriptionService,
            INotificationService notificationService,
            IBackgroundJobClient backgroundJobClient,
            IDateTimeNowProvider dateTimeNowProvider,
            ILoggerFactory loggerFactory) =>
        {
            var logger = loggerFactory.CreateLogger("vipps-subscribe-callback");

            var pendingAgreements = dbContext.GetPendingAgreements();

            var tasks = pendingAgreements.Select(async agreement =>
            {
                var retries = 0;
                var agreementInVipps = await vippsApiClient.GetAgreement(agreement.Id);

                while (agreementInVipps.Status == VippsAgreementStatus.Pending && retries < 5)
                {
                    retries++;

                    await Task.Delay(750);

                    agreementInVipps = await vippsApiClient.GetAgreement(agreement.Id);
                }

                if (agreementInVipps.Status == VippsAgreementStatus.Stopped ||
                    agreementInVipps.Status == VippsAgreementStatus.Expired)
                {
                    dbContext.Remove(agreement);
                }
                else if (agreementInVipps.Status == VippsAgreementStatus.Active)
                {
                    _ = Task.Run(notificationService.NotifyUserSubscribed);

                    agreement.SetAsActive();
                    backgroundJobClient.Enqueue(() => subscriptionService.UpdateAgreementCharges(agreement.Id));
                }
                else if (agreementInVipps.Status == VippsAgreementStatus.Pending)
                {
                    logger.LogInformation("Subscription was still pending after 5 retries. Returning.");
                }
            });

            await Task.WhenAll(tasks);

            dbContext.SaveChanges();

            return Results.Redirect("/account");
        }).RequireAuthorization();

        app.MapDelete("/api/vippsAgreement", async (
            HttpContext ctx,
            IVippsAgreementService subscriptionService,
            INotificationService notificationService,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);

            var agreementInDb = dbContext.Agreements
                .Where(a => a.Status == AgreementStatus.ACTIVE)
                .FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb == null)
            {
                return Results.BadRequest("No subscription found.");
            }

            await subscriptionService.DeactivateAgreement(agreementInDb.Id);

            _ = Task.Run(notificationService.NotifyUserDeactivated);

            return Results.Ok();

        }).RequireAuthorization();

        app.MapPut("/api/vippsAgreement/reactivate", async (
            HttpContext ctx,
            IVippsAgreementService subscriptionService,
            INotificationService notificationService,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);

            var agreementInDb = dbContext.Agreements
                .Where(a => a.Status == AgreementStatus.UNSUBSCRIBED)
                .FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb == null)
            {
                return Results.BadRequest("No subscription found.");
            }

            await subscriptionService.ReactivateAgreement(agreementInDb.Id);

            _ = Task.Run(notificationService.NotifyUserReactivated);

            return Results.Ok();
        }).RequireAuthorization();
    }
}
