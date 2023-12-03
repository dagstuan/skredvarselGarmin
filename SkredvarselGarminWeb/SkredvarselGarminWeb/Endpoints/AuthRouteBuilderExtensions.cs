using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Extensions.Primitives;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class AuthRouteBuilderExtensions
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapVippsEndpoints();
        app.MapGoogleEndpoints();

        app.MapGet("/logout", async (HttpContext ctx) =>
        {
            await ctx.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

            return Results.Redirect("/");
        }).AllowAnonymous();
    }

    private static void MapGoogleEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/google-login", async (IUserService userService, HttpContext ctx) =>
        {
            if (ctx.User?.Identity == null || !ctx.User.Identity.IsAuthenticated)
            {
                return Results.Challenge(
                    authenticationSchemes: new[] {
                        GoogleDefaults.AuthenticationScheme
                    });
            }

            await userService.RegisterLogin(ctx.User);

            ctx.Request.Query.TryGetValue("returnUrl", out StringValues returnUrl);
            return Results.Redirect(returnUrl.FirstOrDefault() ?? "/");
        });
    }

    private static void MapVippsEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/vipps-login", async (IUserService userService, HttpContext ctx) =>
        {
            if (ctx.User?.Identity == null || !ctx.User.Identity.IsAuthenticated)
            {
                return Results.Challenge(
                    authenticationSchemes: new[] {
                        OpenIdConnectDefaults.AuthenticationScheme
                    });
            }

            await userService.RegisterLogin(ctx.User);

            ctx.Request.Query.TryGetValue("returnUrl", out StringValues returnUrl);
            return Results.Redirect(returnUrl.FirstOrDefault() ?? "/");
        }).AllowAnonymous();
    }
}
