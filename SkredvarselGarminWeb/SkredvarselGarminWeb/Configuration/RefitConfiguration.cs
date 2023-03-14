using Refit;
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

        serviceCollection.AddRefitClient<IVippsApiClient>()
            .ConfigureHttpClient(c =>
            {
                c.BaseAddress = new Uri(vippsOptions.BaseUrl);
            })
            .AddHttpMessageHandler<VippsAuthenticatedHttpClientHandler>();

        var varsomApiSettings = new RefitSettings
        {
            UrlParameterFormatter = new DateOnlyUrlParameterFormatter()
        };
        serviceCollection.AddRefitClient<IVarsomApi>(varsomApiSettings)
            .ConfigureHttpClient(c =>
            {
                c.BaseAddress = new Uri("https://api01.nve.no/hydrology/forecast/avalanche/v6.2.1/api");
            });
    }
}
