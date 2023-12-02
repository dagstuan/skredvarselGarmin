using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Primitives;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.ServiceModels;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class VippsLoginRouteBuilderExtensions
{
    private static string GetClaimValue(this IEnumerable<Claim> claims, string claimType)
        => claims.First(c => c.Type == claimType).Value;

    public static void MapVippsEndpoints(this IEndpointRouteBuilder app)
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

            var user = ctx.User;
            await userService.RegisterLogin(new UserLogin
            {
                Id = user.Claims.GetClaimValue("sub"),
                Name = user.Claims.GetClaimValue("name"),
                Email = user.Claims.GetClaimValue("email"),
                PhoneNumber = user.Claims.GetClaimValue("phone_number")
            });

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
