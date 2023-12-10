using System.IdentityModel.Tokens.Jwt;
using System.Net;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using SkredvarselGarminWeb.Options;

namespace SkredvarselGarminWeb.Configuration;

public static class AuthenticationConfiguration
{
    public static void SetupAuthentication(
        this IServiceCollection serviceCollection,
        VippsOptions vippsOptions,
        AuthOptions authOptions,
        GoogleOptions googleOptions,
        FacebookOptions facebookOptions)
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
            .AddScheme<GarminAuthenticationSchemeOptions, GarminAuthenticationHandler>("Garmin", options => { })
            .AddGoogle(options =>
            {
                options.ClientId = googleOptions.ClientId;
                options.ClientSecret = googleOptions.ClientSecret;
                options.ClaimActions.MapUniqueJsonKey("sub", "sub");
                options.ClaimActions.MapUniqueJsonKey("name", "name");
                options.ClaimActions.MapUniqueJsonKey("email", "email");
            })
            .AddFacebook(options =>
            {
                options.AppId = facebookOptions.AppId;
                options.AppSecret = facebookOptions.AppSecret;
                options.ClaimActions.MapUniqueJsonKey("sub", "id");
                options.ClaimActions.MapUniqueJsonKey("name", "name");
                options.ClaimActions.MapUniqueJsonKey("email", "email");
            });

        serviceCollection.AddAuthorizationBuilder()
            .AddPolicy("Admin", policy =>
                policy.RequireClaim("sub", authOptions.AdminSub))
            .AddPolicy("Garmin", policy =>
            {
                policy.AuthenticationSchemes.Clear();
                policy.AuthenticationSchemes.Add("Garmin");
                policy.RequireAuthenticatedUser();
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

            options.ClaimActions.MapJsonKey("sub", "sub");
            options.ClaimActions.MapUniqueJsonKey("name", "name");
            options.ClaimActions.MapUniqueJsonKey("email", "email");
            options.ClaimActions.MapUniqueJsonKey("phone_number", "phone_number");

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
