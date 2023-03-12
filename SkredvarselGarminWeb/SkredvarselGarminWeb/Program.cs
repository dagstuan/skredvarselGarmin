using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using SkredvarselGarminWeb.Configuration;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VippsApi;
using Refit;
using SkredvarselGarminWeb.Endpoints;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddProblemDetails();

var databaseOptions = builder.Configuration.GetSection("Database").Get<DatabaseOptions>()!;

var connectionStringBuilder = new NpgsqlConnectionStringBuilder
{
    Host = databaseOptions.Host,
    Port = databaseOptions.Port,
    Username = databaseOptions.Username,
    Password = databaseOptions.Password,
    Database = databaseOptions.Database,
    SslMode = SslMode.Prefer,
    TrustServerCertificate = true
};

builder.Services.AddDbContext<SkredvarselDbContext>(options =>
    options.UseNpgsql(connectionStringBuilder.ToString())
        .UseSnakeCaseNamingConvention());

var vippsOptionsSection = builder.Configuration.GetSection("Vipps");
builder.Services.Configure<VippsOptions>(vippsOptionsSection);
var vippsOptions = vippsOptionsSection.Get<VippsOptions>();

builder.Services.SetupAuthentication(builder.Configuration);

builder.Services.AddSingleton<VippsAuthTokenStore>();
builder.Services.AddTransient<VippsAuthenticatedHttpClientHandler>();

builder.Services.AddRefitClient<IVippsApiClient>()
    .ConfigureHttpClient(c =>
    {
        c.BaseAddress = new Uri(vippsOptions!.BaseUrl);
    })
    .AddHttpMessageHandler<VippsAuthenticatedHttpClientHandler>();

var varsomApiSettings = new RefitSettings
{
    UrlParameterFormatter = new DateOnlyUrlParameterFormatter()
};
builder.Services.AddRefitClient<IVarsomApi>(varsomApiSettings)
    .ConfigureHttpClient(c =>
    {
        c.BaseAddress = new Uri("https://api01.nve.no/hydrology/forecast/avalanche/v6.2.1/api");
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
app.MapVarsomApiEndpoints();
app.MapSubscriptionEndpoints();

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
