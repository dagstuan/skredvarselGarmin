using Polly;
using Polly.Extensions.Http;
using Polly.Timeout;
using Refit;
using SkredvarselGarminWeb.NtfyApi;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VippsApi;

namespace SkredvarselGarminWeb.Configuration;

public static class RefitConfiguration
{
    public static void AddRefitClients(this IServiceCollection serviceCollection, VippsOptions vippsOptions)
    {
        serviceCollection.AddSingleton<VippsAuthTokenStore>();
        serviceCollection.AddTransient<VippsAuthenticatedHttpClientHandler>();

        var retryPolicy = HttpPolicyExtensions
            .HandleTransientHttpError()
            .Or<TimeoutRejectedException>() // thrown by Polly's TimeoutPolicy if the inner execution times out
            .WaitAndRetryAsync(new[]
            {
                TimeSpan.FromSeconds(1),
                TimeSpan.FromSeconds(5),
                TimeSpan.FromSeconds(30)
            });

        var timeoutPolicy = Policy.TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(30));

        serviceCollection.AddRefitClient<IVippsApiClient>()
            .ConfigureHttpClient(c =>
            {
                c.BaseAddress = new Uri(vippsOptions.BaseUrl);
            })
            .AddPolicyHandler(retryPolicy)
            .AddPolicyHandler(timeoutPolicy)
            .AddHttpMessageHandler<VippsAuthenticatedHttpClientHandler>();

        var varsomApiSettings = new RefitSettings
        {
            UrlParameterFormatter = new DateOnlyUrlParameterFormatter()
        };
        serviceCollection.AddRefitClient<IVarsomApi>(varsomApiSettings)
            .ConfigureHttpClient(c =>
            {
                c.BaseAddress = new Uri("https://api01.nve.no/hydrology/forecast/avalanche/v6.2.1/api");
            })
            .AddPolicyHandler(retryPolicy)
            .AddPolicyHandler(timeoutPolicy);

        serviceCollection.AddRefitClient<INtfyApiClient>()
            .ConfigureHttpClient(c =>
            {
                c.BaseAddress = new Uri("https://ntfy.sh/skredvarsel");
            });
    }
}
