using Microsoft.AspNetCore.Mvc;
using Refit;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

namespace SkredvarselGarminWeb.Endpoints;

public static class TestEndpointsRouteBuilderExtensions
{
    public static void MapTestEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/test/agreements", async (IVippsApiClient vippsApiClient, [FromQuery] AgreementStatus? status) =>
        {
            return await vippsApiClient.GetAgreements(status ?? AgreementStatus.Active);
        });

        app.MapGet("/api/test/agreements/{id}", async (IVippsApiClient vippsApiClient, string id) =>
        {
            try
            {
                return Results.Ok(await vippsApiClient.GetAgreement(id));
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        });

        app.MapGet("/api/test/agreements/create", async (HttpContext ctx, IVippsApiClient vippsApiClient, SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User.Identity);

            var baseUrl = "https://skredvarsel.app";

            try
            {
                var request = new DraftAgreementRequest
                {
                    CustomerPhoneNumber = user.PhoneNumber,
                    Pricing = new()
                    {
                        Amount = 3000,
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
                    MerchantAgreementUrl = $"{baseUrl}/minSide/",
                    MerchantRedirectUrl = $"{baseUrl}/"
                };

                return Results.Ok(await vippsApiClient.CreateAgreement(request, Guid.NewGuid()));
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        }).RequireAuthorization();

        app.MapGet("/api/test/agreements/{id}/cancel", async (IVippsApiClient vippsApiClient, string id) =>
        {
            var result = await vippsApiClient.PatchAgreement(id, new PatchAgreementRequest
            {
                Status = PatchAgreementStatus.Stopped
            }, Guid.NewGuid());

            if (result.IsSuccessStatusCode)
            {
                return Results.Ok();
            }

            return Results.BadRequest((result.Error as ValidationApiException)!.Content);
        });

        app.MapGet("/api/test/agreements/{id}/charges", async (IVippsApiClient vippsApiClient, string id, [FromQuery] ChargeStatus? status) =>
        {
            try
            {
                return Results.Ok(await vippsApiClient.GetCharges(id, status));
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        });

        app.MapGet("/api/test/agreements/{agreementId}/charges/{chargeId}", async (IVippsApiClient vippsApiClient, string agreementId, string chargeId) =>
        {
            try
            {
                return Results.Ok(await vippsApiClient.GetCharge(agreementId, chargeId));
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        });

        app.MapGet("/api/test/agreements/{agreementId}/charges/create", async (IVippsApiClient vippsApiClient, string agreementId) =>
        {
            try
            {
                var agreement = await vippsApiClient.GetAgreement(agreementId);

                var result = await vippsApiClient.CreateCharge(agreementId, new CreateChargeRequest
                {
                    Amount = agreement.Pricing.Amount,
                    Description = "Månedlig abb!",
                    Due = DateOnly.FromDateTime(DateTime.Now).AddMonths(1),
                    RetryDays = 2,
                }, Guid.NewGuid());

                return Results.Ok(result);
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        });

        app.MapGet("/api/test/agreements/{agreementId}/charges/{chargeId}/cancel", async (IVippsApiClient vippsApiClient, string agreementId, string chargeId) =>
        {
            var charge = await vippsApiClient.GetCharge(agreementId, chargeId);

            var result = await vippsApiClient.CancelCharge(agreementId, chargeId, Guid.NewGuid());

            if (result.IsSuccessStatusCode)
            {
                return Results.Ok();
            }

            return Results.BadRequest((result.Error as ValidationApiException)!.Content);
        });

        app.MapGet("/api/test/agreements/{agreementId}/charges/{chargeId}/capture", async (IVippsApiClient vippsApiClient, string agreementId, string chargeId) =>
        {
            var charge = await vippsApiClient.GetCharge(agreementId, chargeId);

            var result = await vippsApiClient.CaptureCharge(agreementId, chargeId, new CaptureChargeRequest
            {
                Amount = charge.Amount,
                Description = "Månedtlig abonnement på skredvarsel for Garmin."
            }, Guid.NewGuid());

            if (result.IsSuccessStatusCode)
            {
                return Results.Ok();
            }

            return Results.BadRequest((result.Error as ValidationApiException)!.Content);
        });
    }
}
