using System.Text.Json;

using Microsoft.Extensions.Caching.Memory;

using Refit;

using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public partial class LavinprognoserApiClient(
    ILavinprognoserWfsApi wfsApi,
    ILavinprognoserWebsiteApi websiteApi,
    IMemoryCache memoryCache) : ILavinprognoserApi
{
    private static readonly SemaphoreSlim FetchSemaphore = new(10, 10);

    public async Task<IEnumerable<WfsFeature<JsonElement>>> GetAllLocationPolygons()
    {
        var response = await GetAllWfsLocationPolygons("lavinprognoser:location", null);
        return response.Content?.Features ?? [];
    }

    public async Task<IEnumerable<WfsFeature<LavinprognoserLocation>>> GetLocationPolygons()
    {
        var response = await GetTypedWfsLocationPolygons("lavinprognoser:location", null);
        return response.Content?.Features ?? [];
    }

    public async Task<IEnumerable<LavinprognoserDetailedWarning>> GetDetailedWarningsByArea(int areaId, DateOnly from, DateOnly to)
    {
        var slug = SwedishForecastAreaRegistry.GetSlug(areaId);
        if (slug == null) return [];

        return await Task.WhenAll(Enumerable.Range(0, to.DayNumber - from.DayNumber + 1)
            .Select(offset => ResolveWarningForDay(slug, from.AddDays(offset))));
    }

    private async Task<LavinprognoserDetailedWarning> ResolveWarningForDay(string slug, DateOnly day)
    {
        var forecast = await FetchForecastForDate(slug, day);
        var warning = forecast?.ToDetailedWarning();

        return warning != null && warning.ValidTo.Date == day.ToDateTime(TimeOnly.MinValue).Date
            ? warning
            : day.ToMissingWarning();
    }

    private async Task<LavinprognoserWebForecast?> FetchForecastForDate(string slug, DateOnly date)
    {
        var cacheKey = $"LavinprognoserForecast_{slug}_{date:yyyy-MM-dd}";
        if (memoryCache.TryGetValue<LavinprognoserWebForecast?>(cacheKey, out var cached))
        {
            return cached;
        }

        await FetchSemaphore.WaitAsync();
        try
        {
            if (memoryCache.TryGetValue<LavinprognoserWebForecast?>(cacheKey, out cached))
            {
                return cached;
            }

            var response = await GetForecastPage(slug, date);
            if (!response.IsSuccessStatusCode)
            {
                return default;
            }

            LavinprognoserWebForecast? forecast;
            if (response.Content?.Content.Forecast != null)
            {
                forecast = response.Content.Content.Forecast;
            }
            else
            {
                var redirectedSlug = SwedishForecastAreaRegistry.TryGetSlugFromRequestUri(response.RequestMessage?.RequestUri);
                if (redirectedSlug == null || redirectedSlug == slug)
                {
                    forecast = response.Content?.Content.Forecast;
                }
                else
                {
                    var redirectedResponse = await GetForecastPage(redirectedSlug, date);
                    forecast = redirectedResponse.Content?.Content.Forecast;
                }
            }

            memoryCache.Set(cacheKey, forecast, new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1)
            });

            return forecast;
        }
        finally
        {
            FetchSemaphore.Release();
        }
    }

    private Task<ApiResponse<WfsFeatureCollection<JsonElement>>> GetAllWfsLocationPolygons(string typeName, string? cqlFilter) =>
        wfsApi.GetAllLocationPolygons(
            service: "WFS",
            version: "1.0.0",
            request: "GetFeature",
            typeName: typeName,
            outputFormat: "application/json",
            cqlFilter: cqlFilter);

    private Task<ApiResponse<WfsFeatureCollection<LavinprognoserLocation>>> GetTypedWfsLocationPolygons(string typeName, string? cqlFilter) =>
        wfsApi.GetLocationPolygons(
            service: "WFS",
            version: "1.0.0",
            request: "GetFeature",
            typeName: typeName,
            outputFormat: "application/json",
            cqlFilter: cqlFilter);

    private Task<ApiResponse<LavinprognoserWebResponse>> GetForecastPage(string slug, DateOnly date)
    {
        var segments = slug.Split('/', StringSplitOptions.RemoveEmptyEntries);
        var forecastDate = date.ToString("yyyy-MM-dd");

        return segments.Length switch
        {
            1 => websiteApi.GetForecastPage(segments[0], forecastDate),
            2 => websiteApi.GetForecastPage(segments[0], segments[1], forecastDate),
            _ => throw new InvalidOperationException($"Unsupported slug format: '{slug}'.")
        };
    }
}
