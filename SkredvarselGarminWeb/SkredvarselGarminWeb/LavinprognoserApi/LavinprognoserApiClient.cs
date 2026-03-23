using System.Text.Json;

using Refit;

using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public partial class LavinprognoserApiClient(
    ILavinprognoserWfsApi wfsApi,
    ILavinprognoserWebsiteApi websiteApi) : ILavinprognoserApi
{
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
        var response = await GetForecastPage(slug, date);
        if (!response.IsSuccessStatusCode)
        {
            return default;
        }

        if (response.Content?.Content.Forecast != null)
        {
            return response.Content.Content.Forecast;
        }

        var redirectedSlug = SwedishForecastAreaRegistry.TryGetSlugFromRequestUri(response.RequestMessage?.RequestUri);
        if (redirectedSlug == null || redirectedSlug == slug)
        {
            return response.Content?.Content.Forecast;
        }

        var redirectedResponse = await GetForecastPage(redirectedSlug, date);
        return redirectedResponse.Content?.Content.Forecast;
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
