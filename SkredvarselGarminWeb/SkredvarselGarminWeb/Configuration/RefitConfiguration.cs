using System.Text.Json;

using Polly;
using Polly.Extensions.Http;
using Polly.Timeout;

using Refit;

using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.NtfyApi;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VippsApi;

namespace SkredvarselGarminWeb.Configuration;

public static class RefitConfiguration
{
    private static readonly RefitSettings LavinprognoserRefitSettings = new()
    {
        ContentSerializer = new SystemTextJsonContentSerializer(new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
        })
    };

    public static void AddRefitClients(this IServiceCollection serviceCollection, VippsOptions vippsOptions)
    {
        serviceCollection.AddSingleton<VippsAuthTokenStore>();
        serviceCollection.AddTransient<VippsAuthenticatedHttpClientHandler>();

        var retryPolicy = HttpPolicyExtensions
            .HandleTransientHttpError()
            .Or<TimeoutRejectedException>() // thrown by Polly's TimeoutPolicy if the inner execution times out
            .WaitAndRetryAsync(
            [
                TimeSpan.FromSeconds(1),
                TimeSpan.FromSeconds(5),
                TimeSpan.FromSeconds(30)
            ]);

        var timeoutPolicy = Policy.TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(30));

        serviceCollection.AddRefitClient<IVippsApiClient>()
            .ConfigureHttpClient(c => c.BaseAddress = new Uri(vippsOptions.BaseUrl))
            .AddPolicyHandler(retryPolicy)
            .AddPolicyHandler(timeoutPolicy)
            .AddHttpMessageHandler<VippsAuthenticatedHttpClientHandler>();

        var varsomApiSettings = new RefitSettings
        {
            UrlParameterFormatter = new DateOnlyUrlParameterFormatter()
        };
        serviceCollection.AddRefitClient<IVarsomApi>(varsomApiSettings)
            .ConfigureHttpClient(c => c.BaseAddress = new Uri("https://api01.nve.no/hydrology/forecast/avalanche/v6.3.0/api"))
            .AddPolicyHandler(retryPolicy)
            .AddPolicyHandler(timeoutPolicy);

        serviceCollection.AddTransient<LavinprognoserLoggingHandler>();
        serviceCollection.AddRefitClient<ILavinprognoserWfsApi>(LavinprognoserRefitSettings)
            .ConfigureHttpClient(c => c.BaseAddress = new Uri("https://nvgis.naturvardsverket.se/geoserver/lavinprognoser/"))
            .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
            {
                MaxConnectionsPerServer = 3,
            })
            .AddHttpMessageHandler<LavinprognoserLoggingHandler>()
            .AddPolicyHandler(retryPolicy)
            .AddPolicyHandler(timeoutPolicy);

        serviceCollection.AddRefitClient<ILavinprognoserWebsiteApi>(LavinprognoserRefitSettings)
            .ConfigureHttpClient(c => c.BaseAddress = new Uri("https://www.lavinprognoser.se/"))
            .ConfigurePrimaryHttpMessageHandler(() => new SocketsHttpHandler
            {
                MaxConnectionsPerServer = 3,
            })
            .AddPolicyHandler(retryPolicy)
            .AddPolicyHandler(timeoutPolicy);

        serviceCollection.AddTransient<ILavinprognoserApi, LavinprognoserApiClient>();

        serviceCollection.AddRefitClient<INtfyApiClient>()
            .ConfigureHttpClient(c => c.BaseAddress = new Uri("https://ntfy.sh/skredvarsel"));
    }
}
