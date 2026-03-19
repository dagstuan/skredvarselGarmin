using System.Text.Json;

using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public partial class LavinprognoserApiClient(
    IHttpClientFactory httpClientFactory) : ILavinprognoserApi
{
    public const string WfsHttpClientName = "LavinprognoserWfs";
    public const string WebsiteHttpClientName = "LavinprognoserWebsite";

    private HttpClient WfsClient => httpClientFactory.CreateClient(WfsHttpClientName);
    private HttpClient WebsiteClient => httpClientFactory.CreateClient(WebsiteHttpClientName);
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    public async Task<IEnumerable<WfsFeature<LavinprognoserLocation>>> GetLocationPolygons()
    {
        var url = BuildWfsUrl("lavinprognoser:location", null);
        var collection = await TryGetJsonAsync<WfsFeatureCollection<LavinprognoserLocation>>(WfsClient, url);
        return collection?.Features ?? [];
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
        var response = await WebsiteClient.GetAsync(GetForecastPageUrl(slug, date));
        if (!response.IsSuccessStatusCode)
        {
            return default;
        }

        var forecastResponse = await TryReadJsonAsync<LavinprognoserWebResponse>(response);
        if (forecastResponse?.Content.Forecast != null)
        {
            return forecastResponse.Content.Forecast;
        }

        var redirectedSlug = SwedishForecastAreaRegistry.TryGetSlugFromRequestUri(response.RequestMessage?.RequestUri);
        if (redirectedSlug == null || redirectedSlug == slug)
        {
            return forecastResponse?.Content.Forecast;
        }

        var redirectedResponse = await TryGetJsonAsync<LavinprognoserWebResponse>(WebsiteClient, GetForecastPageUrl(redirectedSlug, date));
        return redirectedResponse?.Content.Forecast;
    }

    private static string GetForecastPageUrl(string fetchSlug, DateOnly date) =>
        $"oversikt-alla-omraden/{fetchSlug}/index.json?forecast_date={date:yyyy-MM-dd}";

    private static async Task<T?> TryGetJsonAsync<T>(HttpClient httpClient, string url)
    {
        var response = await httpClient.GetAsync(url);
        return !response.IsSuccessStatusCode ? default : await TryReadJsonAsync<T>(response);
    }

    private static async Task<T?> TryReadJsonAsync<T>(HttpResponseMessage response)
    {
        if (!response.IsSuccessStatusCode)
        {
            return default;
        }

        var contentType = response.Content.Headers.ContentType?.MediaType;
        return contentType == null || !contentType.Contains("json", StringComparison.OrdinalIgnoreCase)
            ? default
            : await response.Content.ReadFromJsonAsync<T>(JsonOptions);
    }

    private static string BuildWfsUrl(string typeName, string? cqlFilter)
    {
        var query = $"service=WFS&version=1.0.0&request=GetFeature&typeName={Uri.EscapeDataString(typeName)}&outputFormat=application/json";
        if (cqlFilter != null)
        {
            query += $"&CQL_FILTER={Uri.EscapeDataString(cqlFilter)}";
        }
        return $"ows?{query}";
    }
}
