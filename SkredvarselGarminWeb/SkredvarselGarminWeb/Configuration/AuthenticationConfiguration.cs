using System.IdentityModel.Tokens.Jwt;
using System.Net;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
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
            .AddOpenIdConnect(options =>
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

                options.Events.OnUserInformationReceived = (ctx) =>
                {
                    if (ctx.Principal != null)
                    {
                        var rootElement = ctx.User.RootElement;
                        var sub = rootElement.GetString("sub");

                        if (sub == null)
                        {
                            throw new Exception("Invalid login, no sub was returned in user info.");
                        }

                        var dbContext = ctx.HttpContext.RequestServices.GetRequiredService<SkredvarselDbContext>();

                        var name = rootElement.GetString("name")!;
                        var email = rootElement.GetString("email")!;
                        var phoneNumber = rootElement.GetString("phone_number")!;

                        var dateNow = DateOnly.FromDateTime(DateTime.Now);
                        var user = dbContext.Users.Where(u => u.Id == sub).FirstOrDefault();
                        if (user == null)
                        {
                            user = new User
                            {
                                Id = sub,
                                Name = name,
                                Email = email,
                                PhoneNumber = phoneNumber,
                                CreatedDate = dateNow,
                                LastLoggedIn = dateNow
                            };

                            dbContext.Users.Add(user);
                        }

                        if (user.Name != name || user.Email != email || user.PhoneNumber != phoneNumber)
                        {
                            user.Name = name;
                            user.Email = email;
                            user.PhoneNumber = phoneNumber;
                        }

                        user.LastLoggedIn = dateNow;

                        dbContext.SaveChanges();
                    }

                    return Task.CompletedTask;
                };
            })
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
}
