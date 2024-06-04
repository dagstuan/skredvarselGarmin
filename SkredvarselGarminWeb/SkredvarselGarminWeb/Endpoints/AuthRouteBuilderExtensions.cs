using System.Net.Mail;
using System.Security.Claims;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Facebook;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.MagicLink;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class AuthRouteBuilderExtensions
{
    private static List<Claim> GetClaims(this MagicLinkToken magicLinkToken, SkredvarselDbContext dbContext)
    {
        if (magicLinkToken.UserId != null)
        {
            var user = dbContext.GetUserByIdOrNull(magicLinkToken.UserId) ?? throw new Exception("Cant find user");

            List<Claim> claims = [
                new Claim("sub", magicLinkToken.UserId),
                new Claim("email", user.Email),
            ];

            if (user.Name != null)
            {
                claims.Add(new Claim("name", user.Name));
            }

            return claims;
        }
        else
        {
            return [
                new Claim("sub", Guid.NewGuid().ToString()),
                new Claim("email", magicLinkToken.Email),
            ];
        }
    }

    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapLoginEndpoint("/vipps-login", OpenIdConnectDefaults.AuthenticationScheme);
        app.MapLoginEndpoint("/google-login", GoogleDefaults.AuthenticationScheme);
        app.MapLoginEndpoint("/facebook-login", FacebookDefaults.AuthenticationScheme);

        app.MapPost("/email-login-send", async (
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IMagicLinkTokenDataFormat magicLinkTokenDataFormat,
            IEmailService emailService,
            [FromQuery] string returnUrl,
            [FromQuery] string email) =>
        {
            if (ctx.User.Identity?.IsAuthenticated ?? false)
            {
                return Results.BadRequest();
            }

            var success = MailAddress.TryCreate(email, out var _);
            if (!success)
            {
                return Results.BadRequest("Invalid email address");
            }

            var user = dbContext.GetUserByEmailOrNull(email);

            var token = magicLinkTokenDataFormat.Protect(new MagicLinkToken
            {
                Email = email,
                UserId = user?.Id,
                ReturnUrl = returnUrl,
            });

            await emailService.SendLoginEmail(email, token);

            return Results.Ok();
        }).AllowAnonymous();

        app.MapGet("/email-login", async (
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IUserService userService,
            IMagicLinkTokenDataFormat magicLinkTokenDataFormat,
            [FromQuery] string token) =>
        {
            var magicLinkToken = magicLinkTokenDataFormat.Unprotect(token);
            if (magicLinkToken != null)
            {
                var isAuthenticated = ctx.User.Identity?.IsAuthenticated ?? false;
                if (!isAuthenticated && DateTime.Now < magicLinkToken.ExpirationTime)
                {
                    var claims = magicLinkToken.GetClaims(dbContext);
                    var principal = new ClaimsPrincipal(new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme));

                    await ctx.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);

                    userService.RegisterLogin(principal);
                }

                return Results.Redirect(magicLinkToken.ReturnUrl);
            }

            return Results.Redirect("/login-failed");
        }).ExcludeFromDescription();

        app.MapGet("/logout", async (HttpContext ctx) =>
        {
            await ctx.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme, new()
            {
                RedirectUri = "/"
            });
        }).AllowAnonymous();
    }

    private static void MapLoginEndpoint(this IEndpointRouteBuilder app, string endpoint, string authenticationScheme)
    {
        app.MapGet(endpoint, (IUserService userService, HttpContext ctx) =>
        {
            if (ctx.User?.Identity == null || !ctx.User.Identity.IsAuthenticated)
            {
                return Results.Challenge(authenticationSchemes: [authenticationScheme]);
            }

            userService.RegisterLogin(ctx.User);

            ctx.Request.Query.TryGetValue("returnUrl", out StringValues returnUrl);
            return Results.Redirect(returnUrl.FirstOrDefault() ?? "/");
        }).ExcludeFromDescription();
    }
}
