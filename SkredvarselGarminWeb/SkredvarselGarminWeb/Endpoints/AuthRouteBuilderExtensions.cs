using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Facebook;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Extensions.Primitives;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class AuthRouteBuilderExtensions
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapLoginEndpoint("/vipps-login", OpenIdConnectDefaults.AuthenticationScheme);
        app.MapLoginEndpoint("/google-login", GoogleDefaults.AuthenticationScheme);
        app.MapLoginEndpoint("/facebook-login", FacebookDefaults.AuthenticationScheme);

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
        app.MapGet(endpoint, async (IUserService userService, HttpContext ctx) =>
        {
            if (ctx.User?.Identity == null || !ctx.User.Identity.IsAuthenticated)
            {
                return Results.Challenge(authenticationSchemes: [authenticationScheme]);
            }

            await userService.RegisterLogin(ctx.User);

            ctx.Request.Query.TryGetValue("returnUrl", out StringValues returnUrl);
            return Results.Redirect(returnUrl.FirstOrDefault() ?? "/");
        });
    }
}
