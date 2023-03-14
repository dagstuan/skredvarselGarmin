using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

namespace SkredvarselGarminWeb.Endpoints;

public static class SubscriptionEndpointsRouteBuilderExtensions
{
    public static void MapSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/createSubscription", async (HttpContext ctx, IVippsApiClient vippsApiClient, SkredvarselDbContext dbContext) =>
        {
            // var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var userId = "2eb44f8c-37b8-4463-914a-1b360e16d3aa";
            var userPhoneNumber = "4798839590";

            var agreementInDb = dbContext.Agreements.FirstOrDefault(a => a.UserId == userId);
            if (agreementInDb != null)
            {
                // TODO: Redirect til minside.
                ctx.Response.Redirect($"{ctx.Request.Scheme}://{ctx.Request.Host}/minSide");
                return;
            }

            var baseUrl = "https://skredvarsel.app";

            var request = new DraftAgreementRequest
            {
                CustomerPhoneNumber = userPhoneNumber,
                Pricing = new()
                {
                    Amount = 3000,
                    Currency = "NOK",
                    Type = "LEGACY"
                },
                Interval = new()
                {
                    Count = 1,
                    Unit = PeriodUnit.Year
                },
                Campaign = new()
                {
                    Price = 100,
                    Type = CampaignType.PeriodCampaign,
                    Period = new()
                    {
                        Count = 1,
                        Unit = PeriodUnit.Month
                    }
                },
                InitialCharge = new()
                {
                    Amount = 100,
                    Description = "Første måned"
                },
                ProductName = "Skredvarsel for Garmin",
                MerchantAgreementUrl = $"{baseUrl}/minSide",
                MerchantRedirectUrl = $"{baseUrl}/"
            };

            var createdAgreement = await vippsApiClient.CreateAgreement(request, Guid.NewGuid());

            dbContext.Add(new Entities.Agreement
            {
                Id = createdAgreement.AgreementId,
                UserId = userId,
                ConfirmationUrl = createdAgreement.VippsConfirmationUrl,
                Start = DateOnly.FromDateTime(DateTime.Now),
                NextChargeId = createdAgreement.ChargeId,
                NextChargeDate = DateOnly.FromDateTime(DateTime.Now)
            });
            dbContext.SaveChanges();

            ctx.Response.Redirect(createdAgreement.VippsConfirmationUrl);
            //}).RequireAuthorization();
        });

        app.MapGet("/api/subscription", async (HttpContext ctx, IVippsApiClient vippsApiClient, SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var agreementInDb = dbContext.Agreements.FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb != null)
            {
                var agreementInVipps = await vippsApiClient.GetAgreement(agreementInDb.Id);

                return Results.Ok(agreementInVipps);
            }

            return Results.NoContent();
        }).RequireAuthorization();

        app.MapDelete("/api/subscription", async (HttpContext ctx, IVippsApiClient vippsApiClient, SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var agreementInDb = dbContext.Agreements.FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb != null)
            {
                var result = await vippsApiClient.PatchAgreement(agreementInDb.Id, new PatchAgreementRequest
                {
                    Status = PatchAgreementStatus.Stopped
                }, Guid.NewGuid());

                return Results.Ok();
            }

            return Results.NoContent();
        }).RequireAuthorization();
    }
}
