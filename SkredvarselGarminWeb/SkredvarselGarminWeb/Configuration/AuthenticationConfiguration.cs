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
            .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options
                => options.ExpireTimeSpan = TimeSpan.FromMinutes(60))
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
                policy.RequireClaim("email", authOptions.AdminEmail))
            .AddPolicy("Garmin", policy =>
            {
                policy.AuthenticationSchemes.Clear();
                policy.AuthenticationSchemes.Add("Garmin");
                policy.RequireAuthenticatedUser();
            });
    }
}
