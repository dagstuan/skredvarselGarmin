using Hangfire;

using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

using Resend;

using SkredvarselGarminWeb.Configuration;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints;
using SkredvarselGarminWeb.Hangfire;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Middlewares;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

using Stripe;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

builder.Services.AddProblemDetails();
builder.Services.AddMemoryCache();
builder.Services.AddHttpContextAccessor();

var dataProtectionPath = builder.Configuration.GetValue<string>("DataProtectionPath");
builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(dataProtectionPath!));

var databaseOptions = builder.Configuration.GetSection("Database").Get<DatabaseOptions>()!;
builder.Services.ConfigureDatabase(databaseOptions);
builder.Services.ConfigureHangfireServices(databaseOptions);

var vippsOptionsSection = builder.Configuration.GetSection("Vipps");
builder.Services.Configure<VippsOptions>(vippsOptionsSection);
var vippsOptions = vippsOptionsSection.Get<VippsOptions>();

var stripeOptionsSection = builder.Configuration.GetSection("Stripe");
builder.Services.Configure<StripeOptions>(stripeOptionsSection);

builder.Services.AddTransient<IStripeClient>(f => new StripeClient(stripeOptionsSection.Get<StripeOptions>()!.ApiKey));

StripeConfiguration.ApiKey = stripeOptionsSection.Get<StripeOptions>()!.ApiKey;

var authOptions = builder.Configuration.GetSection("Auth").Get<AuthOptions>();
var googleOptions = builder.Configuration.GetSection("Google").Get<GoogleOptions>();
var facebookOptions = builder.Configuration.GetSection("Facebook").Get<FacebookOptions>();

builder.Services.AddTransient<IDateTimeNowProvider, DateTimeNowProvider>();
builder.Services.AddTransient<IGarminAuthenticationService, GarminAuthenticationService>();
builder.Services.AddTransient<IVippsAgreementService, VippsAgreementService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IStripeService, StripeService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IForecastAreaService, ForecastAreaService>();

builder.Services.SetupAuthentication(vippsOptions!, authOptions!, googleOptions!, facebookOptions!);
builder.Services.AddRefitClients(vippsOptions!);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.CustomSchemaIds(type => type.ToString());
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "SkredvarselGarminWeb", Version = "v1" });
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

app.UseCookiePolicy();
app.UseAuthentication();
app.UseAuthorization();

app.MapHealthChecks("/healthz");

app.MapUserEndpoints();
app.MapAuthEndpoints();
app.MapVarsomApiEndpoints(authOptions!);
app.MapStripeSubscriptionEndpoints();
app.MapVippsSubscriptionEndpoints();
app.MapSubscriptionApiEndpoints();
app.MapWatchApiEndpoints();
app.MapAdminEndpoints();
app.MapForecastAreaEndpoints();

app.MapHangfireDashboard();

app.UseMiddleware<SwaggerOAuthMiddleware>();
app.UseSwagger();
app.UseSwaggerUI();

using (var scope = app.Services.CreateScope())
{
    var recurringJobManager = scope.ServiceProvider.GetRequiredService<IRecurringJobManager>();
    recurringJobManager.AddOrUpdate<HangfireService>("UpdatePendingAgreements", s => s.UpdatePendingAgreements(), "*/10 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("RemoveStalePendingAgreements", s => s.RemoveStalePendingAgreements(), "*/10 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("UpdateAgreementCharges", s => s.UpdateAgreementCharges(), "5 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("RemoveStaleWatchAddRequests", s => s.RemoveStaleWatchAddRequests(), "*/5 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("RemoveStaleUsers", s => s.RemoveStaleUsers(), "0 3 * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("CreateNextChargeForAgreements", s => s.CreateNextChargeForAgreements(), Cron.Hourly);

    recurringJobManager.RemoveIfExists("CreateNextChargeForAgreement");
}

if (app.Environment.IsDevelopment())
{
    app.MapTestEndpoints();

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
    app.UseStaticFiles(new StaticFileOptions
    {
        OnPrepareResponse = ctx =>
        {
            if (!ctx.File.Name.EndsWith(".html"))
            {
                ctx.Context.Response.Headers.Append("Cache-Control", $"public, max-age=31536000");
            }
        },
    });
    app.MapFallbackToFile("index.html");
}

app.Run();
