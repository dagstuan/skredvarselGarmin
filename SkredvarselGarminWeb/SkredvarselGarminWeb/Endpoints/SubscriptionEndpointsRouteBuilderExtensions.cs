using Hangfire;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VippsApi;

using AgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;

namespace SkredvarselGarminWeb.Endpoints;

public static class SubscriptionEndpointsRouteBuilderExtensions
{
    public static void MapSubscriptionApiEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/subscription", async (
            HttpContext ctx,
            IVippsApiClient vippsApiClient,
            IVippsAgreementService subscriptionService,
            IBackgroundJobClient backgroundJobClient,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);

            var vippsAgreementsInDb = dbContext.Agreements
                .OrderByDescending(a => a.Created)
                .Where(a => a.UserId == user.Id)
                .ToList();

            var stripeSubscriptionsInDb = dbContext.StripeSubscriptions
                .OrderByDescending(ss => ss.Created)
                .Where(ss => ss.UserId == user.Id)
                .ToList();

            var activeVippsAgreement = vippsAgreementsInDb
                    .FirstOrDefault(a => a.Status == AgreementStatus.ACTIVE || a.Status == AgreementStatus.UNSUBSCRIBED);
            if (activeVippsAgreement != null)
            {
                return Results.Ok(new SubscriptionResponse
                {
                    SubscriptionType = SubscriptionType.Vipps,
                    VippsAgreementStatus = activeVippsAgreement.Status,
                    NextChargeDate = activeVippsAgreement.NextChargeDate,
                });
            }

            var pendingVippsAgreement = vippsAgreementsInDb.FirstOrDefault(a => a.Status == AgreementStatus.PENDING);
            if (pendingVippsAgreement != null)
            {
                var agreementInVipps = await vippsApiClient.GetAgreement(pendingVippsAgreement.Id);

                if (agreementInVipps.Status == VippsAgreementStatus.Active)
                {
                    pendingVippsAgreement.SetAsActive();
                    dbContext.SaveChanges();

                    backgroundJobClient.Enqueue(() => subscriptionService.UpdateAgreementCharges(pendingVippsAgreement.Id));
                }

                return Results.Ok(new SubscriptionResponse
                {
                    SubscriptionType = SubscriptionType.Vipps,
                    VippsAgreementStatus = pendingVippsAgreement.Status,
                    NextChargeDate = pendingVippsAgreement.NextChargeDate,
                    VippsConfirmationUrl = pendingVippsAgreement.ConfirmationUrl
                });
            }

            var activeStripeSubscription = stripeSubscriptionsInDb
                .FirstOrDefault(ss => ss.Status == Entities.StripeSubscriptionStatus.ACTIVE
                    || ss.Status == Entities.StripeSubscriptionStatus.UNSUBSCRIBED);
            return activeStripeSubscription != null
                ? Results.Ok(new SubscriptionResponse
                {
                    SubscriptionType = SubscriptionType.Stripe,
                    StripeSubscriptionStatus = activeStripeSubscription.Status,
                    NextChargeDate = activeStripeSubscription.NextChargeDate,
                })
                : Results.NoContent();
        }).RequireAuthorization();
    }
}
