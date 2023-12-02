using System.IdentityModel.Tokens.Jwt;
using System.Net;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using SkredvarselGarminWeb.Options;

namespace SkredvarselGarminWeb.Configuration;

public static class AuthenticationConfiguration
{
    public static void SetupAuthentication(this IServiceCollection serviceCollection, VippsOptions vippsOptions, AuthOptions authOptions)
    {
        JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();
        serviceCollection.AddAuthentication(options =>
            {
                options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
            })
            .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
            {
                options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
            })
            .AddVipps(vippsOptions)
            .AddScheme<GarminAuthenticationSchemeOptions, GarminAuthenticationHandler>("Garmin", options => { });

        serviceCollection.AddAuthorization(options =>
        {
            options.AddPolicy("Admin", policy =>
                policy.RequireClaim("sub", authOptions.AdminSub));

            options.AddPolicy("Garmin", policy =>
            {
                policy.AuthenticationSchemes.Clear();
                policy.AuthenticationSchemes.Add("Garmin");
                policy.RequireAuthenticatedUser();
            });
        });
    }

    public static AuthenticationBuilder AddVipps(this AuthenticationBuilder builder, VippsOptions vippsOptions)
    {
        return builder.AddOpenIdConnect(options =>
        {
            options.Authority = vippsOptions?.Authority;
            options.ClientId = vippsOptions?.ClientId;
            options.ClientSecret = vippsOptions?.ClientSecret;
            options.ResponseType = "code";
            options.CallbackPath = "/signin-oidc";
            options.AccessDeniedPath = "/";

            options.GetClaimsFromUserInfoEndpoint = true;

            options.Scope.Clear();
            options.Scope.Add("openid");
            options.Scope.Add("name");
            options.Scope.Add("email");
            options.Scope.Add("phoneNumber");

            options.ClaimActions.MapJsonKey("phone_number", "phone_number");
            options.ClaimActions.MapJsonKey("sub", "sub");

            options.Events.OnRedirectToIdentityProvider = (ctx) =>
            {
                if (ctx.Request.Path.StartsWithSegments("/api"))
                {
                    if (ctx.Response.StatusCode == (int)HttpStatusCode.OK)
                    {
                        ctx.Response.StatusCode = 401;
                    }

                    ctx.HandleResponse();
                }

                return Task.CompletedTask;
            };
        });
    }
}
