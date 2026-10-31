using System.Security.Claims;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Helpers;
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
            [FromQuery] string? lang,
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IStripeClient stripeClient,
            IOptions<StripeOptions> stripeOptions) =>
        {
            var baseUrl = ctx.GetBaseUrl();
            var languagePrefix = FrontendLanguage.GetPathPrefix(lang);
            var user = dbContext.GetUserOrNull(ctx.User);

            if (user != null)
            {
                var userHasActiveStripeSubscriptions = dbContext.StripeSubscriptions
                    .Where(ss => ss.UserId == user.Id)
                    .WhereActive()
                    .Any();

                if (userHasActiveStripeSubscriptions)
                {
                    return Results.Redirect(string.IsNullOrEmpty(languagePrefix)
                        ? "/stripe-customer-portal"
                        : $"/stripe-customer-portal?lang={lang}");
                }
            }

            var successUrl = $"{baseUrl}/stripe-subscribe-callback?session_id={{CHECKOUT_SESSION_ID}}";
            if (!string.IsNullOrWhiteSpace(watchKey))
            {
                successUrl += $"&watchKey={Uri.EscapeDataString(watchKey)}";
            }
            if (!string.IsNullOrEmpty(languagePrefix))
            {
                successUrl += $"&lang={lang}";
            }

            var cancelUrl = user == null
                ? $"{baseUrl}{languagePrefix}/subscribe"
                : $"{baseUrl}{languagePrefix}/account";
            if (!string.IsNullOrWhiteSpace(watchKey))
            {
                cancelUrl += $"?watchKey={Uri.EscapeDataString(watchKey)}";
            }

            var options = new SessionCreateOptions
            {
                SuccessUrl = successUrl,
                CancelUrl = cancelUrl,
                Locale = FrontendLanguage.GetStripeLocale(lang),
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
            IStripeService stripeService,
            IUserService userService,
            [FromQuery(Name = "session_id")] string sessionId,
            [FromQuery] string? watchKey,
            [FromQuery] string? lang,
            ILoggerFactory loggerFactory) =>
        {
            var logger = loggerFactory.CreateLogger("stripe-subscribe-callback");
            logger.LogInformation("Received stripe subscribe callback.");

            stripeService.FulfillCheckoutSession(sessionId);
            var user = stripeService.GetUserForFulfilledCheckoutSession(sessionId);
            var principal = GetStripeCheckoutPrincipal(user);

            await ctx.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);
            userService.RegisterLogin(principal);

            var redirectUrl = $"{FrontendLanguage.GetPathPrefix(lang)}/account";
            if (!string.IsNullOrWhiteSpace(watchKey))
            {
                redirectUrl += $"?watchKey={Uri.EscapeDataString(watchKey)}";
            }

            return Results.Redirect(redirectUrl);
        }).AllowAnonymous();

        app.MapGet("/stripe-customer-portal", async (
            [FromQuery] string? lang,
            HttpContext ctx,
            IStripeClient stripeClient,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);
            var baseUrl = ctx.GetBaseUrl();

            var options = new Stripe.BillingPortal.SessionCreateOptions
            {
                Customer = user.StripeCustomerId,
                ReturnUrl = $"{baseUrl}{FrontendLanguage.GetPathPrefix(lang)}/account",
                Locale = FrontendLanguage.GetStripeLocale(lang),
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
