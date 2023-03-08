using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SkredvarselGarminWeb.Configuration;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.VarsomApi;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();

builder.Services.AddTransient<IVarsomApi, VarsomApi>();
builder.Services.AddControllers();

var connectionString = builder.Configuration.GetSection("Database").GetValue<string>("ConnectionString");
builder.Services.AddDbContext<SkredvarselDbContext>(options =>
    options.UseNpgsql(connectionString)
        .UseSnakeCaseNamingConvention());

var oidcOptions = builder.Configuration.GetSection("Oidc").Get<OidcOptions>();

builder.Services.AddAuthentication(options =>
    {
        options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
    {
        options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
        options.Cookie.SameSite = SameSiteMode.None;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    })
    .AddOpenIdConnect(options =>
    {
        options.Authority = oidcOptions?.Authority;
        options.ClientId = oidcOptions?.ClientId;
        options.ClientSecret = oidcOptions?.ClientSecret;
        options.ResponseType = "code";
        options.CallbackPath = "/signin-oidc";

        options.NonceCookie.SecurePolicy = CookieSecurePolicy.Always;
        options.CorrelationCookie.SecurePolicy = CookieSecurePolicy.Always;

        options.GetClaimsFromUserInfoEndpoint = true;

        options.TokenValidationParameters = new TokenValidationParameters
        {
            NameClaimType = "name",
        };

        options.Scope.Clear();
        options.Scope.Add("openid");
        options.Scope.Add("name");
        options.Scope.Add("email");

        options.Events.OnUserInformationReceived = (ctx) =>
        {
            if (ctx.Principal != null)
            {
                var rootElement = ctx.User.RootElement;
                var sub = rootElement.GetString("sub");

                if (sub != null)
                {
                    var dbContext = ctx.HttpContext.RequestServices.GetRequiredService<SkredvarselDbContext>();

                    var user = dbContext.Users.Where(u => u.Id == sub).FirstOrDefault();
                    if (user == null)
                    {
                        var userEntity = new User
                        {
                            Id = sub,
                            Name = rootElement.GetString("name") ?? string.Empty,
                            Email = rootElement.GetString("email") ?? string.Empty,
                        };

                        dbContext.Users.Add(userEntity);

                        dbContext.SaveChanges();
                    }
                }
            }

            return Task.CompletedTask;
        };
    });

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SkredvarselDbContext>();
    db.Database.Migrate();
}

app.Use(next => context =>
{
    if (string.Equals(context.Request.Headers["X-Forwarded-Proto"], "https", StringComparison.OrdinalIgnoreCase))
    {
        context.Request.Scheme = "https";
    }

    return next(context);
});

app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapVippsEndpoints();

app.MapControllers();

if (app.Environment.IsDevelopment())
{
    // Redirect all non-matched requests to SPA.
    app.Use(async (context, next) =>
    {
        var endpoint = context.GetEndpoint();

        if (endpoint == null)
        {
            var redirectUrl = UriHelper.BuildAbsolute(
                "http",
                new HostString("localhost:5173"),
                context.Request.PathBase,
                context.Request.Path,
                context.Request.QueryString);

            context.Response.Redirect(redirectUrl);
        }
        else
        {
            await next();
        }
    });
}
else
{
    app.MapFallbackToFile("index.html");
}

app.Run();
