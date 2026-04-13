using System.Security.Claims;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

using Stripe;
using Stripe.Checkout;

namespace SkredvarselGarminWeb.Endpoints;

public static class StripeSubscriptionEndpointsRouteBuilderExtensions
{
    private static ClaimsPrincipal GetStripeCheckoutPrincipal(User user)
    {
        List<Claim> claims =
        [
            new("sub", user.Id),
            new("email", user.Email),
        ];

        if (!string.IsNullOrWhiteSpace(user.Name))
        {
            claims.Add(new Claim("name", user.Name));
        }

        return new ClaimsPrincipal(new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme));
    }

    public static void MapStripeSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/createStripeSubscription", async (
            [FromQuery] string? watchKey,
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IStripeClient stripeClient,
            IOptions<StripeOptions> stripeOptions) =>
        {
            var baseUrl = ctx.GetBaseUrl();
            var user = dbContext.GetUserOrNull(ctx.User);

            if (user != null)
            {
                var userHasActiveStripeSubscriptions = dbContext.StripeSubscriptions
                    .Where(ss => ss.UserId == user.Id)
                    .Where(ss => ss.Status == StripeSubscriptionStatus.ACTIVE)
                    .Any();

                if (userHasActiveStripeSubscriptions)
                {
                    return Results.Redirect("/stripe-customer-portal");
                }
            }

            var successUrl = $"{baseUrl}/stripe-subscribe-callback?session_id={{CHECKOUT_SESSION_ID}}";
            if (!string.IsNullOrWhiteSpace(watchKey))
            {
                successUrl += $"&watchKey={Uri.EscapeDataString(watchKey)}";
            }

            var cancelUrl = user == null ? $"{baseUrl}/subscribe" : $"{baseUrl}/account";
            if (!string.IsNullOrWhiteSpace(watchKey))
            {
                cancelUrl += $"?watchKey={Uri.EscapeDataString(watchKey)}";
            }

            var options = new SessionCreateOptions
            {
                SuccessUrl = successUrl,
                CancelUrl = cancelUrl,
                Mode = "subscription",
                LineItems = [
                    new SessionLineItemOptions
                    {
                        Price = stripeOptions.Value.PriceId,
                        Quantity = 1,
                    }
                ],
            };

            if (user != null)
            {
                options.ClientReferenceId = user.Id;

                if (string.IsNullOrEmpty(user.StripeCustomerId))
                {
                    options.CustomerEmail = user.Email;
                }
                else
                {
                    options.Customer = user.StripeCustomerId;
                }
            }

            var service = new SessionService(stripeClient);
            var session = await service.CreateAsync(options);

            return Results.Redirect(session.Url);
        }).AllowAnonymous();

        app.MapGet("/stripe-subscribe-callback", async (
            HttpContext ctx,
            IStripeClient stripeClient,
            IStripeService stripeService,
            IUserService userService,
            [FromQuery(Name = "session_id")] string sessionId,
            [FromQuery] string? watchKey,
            ILoggerFactory loggerFactory) =>
        {
            var logger = loggerFactory.CreateLogger("stripe-subscribe-callback");
            logger.LogInformation("Received stripe subscribe callback.");

            var service = new SessionService(stripeClient);
            var session = await service.GetAsync(sessionId);

            var user = stripeService.GetOrCreateUserForCheckoutSession(session);
            var principal = GetStripeCheckoutPrincipal(user);

            await ctx.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);
            userService.RegisterLogin(principal);

            stripeService.StoreNewSubscriptionIfNotExists(session);

            var redirectUrl = "/account";
            if (!string.IsNullOrWhiteSpace(watchKey))
            {
                redirectUrl += $"?watchKey={Uri.EscapeDataString(watchKey)}";
            }

            return Results.Redirect(redirectUrl);
        }).AllowAnonymous();

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
                    stripeOptions.Value.WebhookSecret,
                    throwOnApiVersionMismatch: false
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
