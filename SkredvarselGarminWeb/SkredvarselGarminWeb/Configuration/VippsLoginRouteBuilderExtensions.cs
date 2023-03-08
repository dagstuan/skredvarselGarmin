using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Extensions.Primitives;

namespace SkredvarselGarminWeb.Configuration;

public static class VippsLoginRouteBuilderExtensions
{
    public static void MapVippsEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/vipps-login", async (ctx) =>
        {
            if (ctx.User?.Identity == null || !ctx.User.Identity.IsAuthenticated)
            {
                await ctx.ChallengeAsync(OpenIdConnectDefaults.AuthenticationScheme);
                return;
            }

            ctx.Request.Query.TryGetValue("returnUrl", out StringValues returnUrl);

            ctx.Response.Redirect(returnUrl.FirstOrDefault() ?? "/");
        }).AllowAnonymous();

        app.MapGet("/vipps-logout", async (ctx) =>
        {
            await ctx.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

            ctx.Response.Redirect("/");
        }).AllowAnonymous();

        app.MapGet("/vipps-user", async (HttpContext ctx) =>
        {
            var result = await ctx.AuthenticateAsync();

            if (!result.Succeeded)
            {
                return Results.Ok(null);
            }
            else
            {
                return Results.Ok(new
                {
                    result.Principal.Identity!.Name
                });
            }
        });
    }
}
