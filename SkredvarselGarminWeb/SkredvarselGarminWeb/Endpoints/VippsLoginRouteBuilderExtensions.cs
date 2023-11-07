using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Extensions.Primitives;

namespace SkredvarselGarminWeb.Endpoints;

public static class VippsLoginRouteBuilderExtensions
{
    public static void MapVippsEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/vipps-login", (HttpContext ctx) =>
        {
            if (ctx.User?.Identity == null || !ctx.User.Identity.IsAuthenticated)
            {
                return Results.Challenge(
                    authenticationSchemes: new[] {
                        OpenIdConnectDefaults.AuthenticationScheme
                    });
            }

            ctx.Request.Query.TryGetValue("returnUrl", out StringValues returnUrl);

            return Results.Redirect(returnUrl.FirstOrDefault() ?? "/");
        }).AllowAnonymous();

        app.MapGet("/vipps-logout", async (HttpContext ctx) =>
        {
            await ctx.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

            return Results.Redirect("/");
        }).AllowAnonymous();
    }
}
