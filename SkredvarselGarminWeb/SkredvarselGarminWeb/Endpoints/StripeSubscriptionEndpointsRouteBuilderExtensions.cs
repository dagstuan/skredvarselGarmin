using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

using Stripe;
using Stripe.Checkout;

namespace SkredvarselGarminWeb.Endpoints;

public static class StripeSubscriptionEndpointsRouteBuilderExtensions
{
    public static void MapStripeSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/createStripeSubscription", async (
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IUserService userService,
            IStripeClient stripeClient,
            IOptions<StripeOptions> stripeOptions) =>
        {
            var user = userService.GetUserOrRegisterLogin(ctx.User);

            var baseUrl = ctx.GetBaseUrl();

            var userHasActiveStripeSubscriptions = dbContext.StripeSubscriptions
                .Where(ss => ss.UserId == user.Id)
                .Where(ss => ss.Status == Entities.StripeSubscriptionStatus.ACTIVE)
                .Any();

            if (userHasActiveStripeSubscriptions)
            {
                return Results.Redirect("/stripe-customer-portal");
            }

            var options = new SessionCreateOptions
            {
                SuccessUrl = $"{baseUrl}/stripe-subscribe-callback?session_id={{CHECKOUT_SESSION_ID}}",
                CancelUrl = $"{baseUrl}/account",
                Mode = "subscription",
                CustomerEmail = user.StripeCustomerId is { Length: > 0 } ? user.Email : null,
                Customer = user.StripeCustomerId,
                ClientReferenceId = user.Id,
                LineItems = [
                    new SessionLineItemOptions
                    {
                        Price = stripeOptions.Value.PriceId,
                        Quantity = 1,
                    }
                ],
            };

            var service = new SessionService(stripeClient);
            var session = await service.CreateAsync(options);

            return Results.Redirect(session.Url);
        }).RequireAuthorization();

        app.MapGet("/stripe-subscribe-callback", async (
            HttpContext ctx,
            IStripeClient stripeClient,
            IStripeService stripeService,
            [FromQuery(Name = "session_id")] string sessionId,
            ILoggerFactory loggerFactory) =>
        {
            var logger = loggerFactory.CreateLogger("stripe-subscribe-callback");
            logger.LogInformation("Received stripe subscribe callback.");

            var baseUrl = ctx.GetBaseUrl();
            var service = new SessionService(stripeClient);
            var session = await service.GetAsync(sessionId);

            stripeService.StoreNewSubscriptionIfNotExists(session);

            return Results.Redirect("/account");
        }).RequireAuthorization();

        app.MapGet("/stripe-customer-portal", async (
            HttpContext ctx,
            IStripeClient stripeClient,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);
            var baseUrl = ctx.GetBaseUrl();

            var options = new Stripe.BillingPortal.SessionCreateOptions
            {
                Customer = user.StripeCustomerId,
                ReturnUrl = $"{baseUrl}/account",
            };

            var service = new Stripe.BillingPortal.SessionService(stripeClient);
            var session = await service.CreateAsync(options);

            return Results.Redirect(session.Url);
        }).RequireAuthorization();

        app.MapPost("/stripe-webhook", async (
            HttpContext ctx,
            [FromHeader(Name = "Stripe-Signature")] string stripeSignature,
            IStripeService stripeService,
            IOptions<StripeOptions> stripeOptions,
            ILoggerFactory loggerFactory) =>
        {
            var logger = loggerFactory.CreateLogger("stripe-webhook");

            var json = await new StreamReader(ctx.Request.Body).ReadToEndAsync();

            Event stripeEvent;
            try
            {
                stripeEvent = EventUtility.ConstructEvent(
                    json,
                    stripeSignature,
                    stripeOptions.Value.WebhookSecret
                );
                logger.LogInformation("Webhook notification with type: {eventType} found for {eventId}", stripeEvent.Type, stripeEvent.Id);

                stripeService.HandleWebhook(stripeEvent);
            }
            catch (Exception e)
            {
                logger.LogError(e, "Failed to parse stripe webhook event.");
                return Results.BadRequest();
            }

            return Results.Ok();
        });
    }
}
