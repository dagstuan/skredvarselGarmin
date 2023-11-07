using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Configuration;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Endpoints;
using Hangfire;
using SkredvarselGarminWeb.Hangfire;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;
using Microsoft.AspNetCore.DataProtection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

builder.Services.AddProblemDetails();
builder.Services.AddMemoryCache();

var dataProtectionPath = builder.Configuration.GetValue<string>("DataProtectionPath");
builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(dataProtectionPath!));

var databaseOptions = builder.Configuration.GetSection("Database").Get<DatabaseOptions>()!;
builder.Services.ConfigureDatabase(databaseOptions);
builder.Services.ConfigureHangfireServices(databaseOptions);

var vippsOptionsSection = builder.Configuration.GetSection("Vipps");
builder.Services.Configure<VippsOptions>(vippsOptionsSection);
var vippsOptions = vippsOptionsSection.Get<VippsOptions>();

builder.Services.AddTransient<IDateTimeNowProvider, DateTimeNowProvider>();
builder.Services.AddTransient<IGarminAuthenticationService, GarminAuthenticationService>();
builder.Services.AddTransient<ISubscriptionService, SubscriptionService>();

var authOptions = builder.Configuration.GetSection("Auth").Get<AuthOptions>();

builder.Services.SetupAuthentication(vippsOptions!, authOptions!);
builder.Services.AddRefitClients(vippsOptions!);

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

app.UseCookiePolicy();
app.UseAuthentication();
app.UseAuthorization();

app.MapHealthChecks("/healthz");

app.MapUserEndpoints();
app.MapVippsEndpoints();
app.MapVarsomApiEndpoints(authOptions!);
app.MapSubscriptionEndpoints();
app.MapWatchApiEndpoints();
app.MapAdminEndpoints();

app.MapHangfireDashboard();

using (var scope = app.Services.CreateScope())
{
    var recurringJobManager = scope.ServiceProvider.GetRequiredService<IRecurringJobManager>();
    recurringJobManager.AddOrUpdate<HangfireService>("UpdatePendingAgreements", s => s.UpdatePendingAgreements(), "*/10 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("RemoveStalePendingAgreements", s => s.RemoveStalePendingAgreements(), "*/10 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("UpdateAgreementCharges", s => s.UpdateAgreementCharges(), "5 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("RemoveStaleWatchAddRequests", s => s.RemoveStaleWatchAddRequests(), "*/5 * * * *");
    recurringJobManager.AddOrUpdate<HangfireService>("RemoveStaleUsers", s => s.RemoveStaleUsers(), "0 3 * * *");
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
    app.MapFallbackToFile("index.html");
}

app.Run();
