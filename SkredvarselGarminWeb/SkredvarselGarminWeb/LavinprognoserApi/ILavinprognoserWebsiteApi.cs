using Refit;

using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public interface ILavinprognoserWebsiteApi
{
    [Get("/oversikt-alla-omraden/{parentSlug}/index.json")]
    Task<ApiResponse<LavinprognoserWebResponse>> GetForecastPage(string parentSlug, [Query][AliasAs("forecast_date")] string forecastDate);

    [Get("/oversikt-alla-omraden/{parentSlug}/{childSlug}/index.json")]
    Task<ApiResponse<LavinprognoserWebResponse>> GetForecastPage(string parentSlug, string childSlug, [Query][AliasAs("forecast_date")] string forecastDate);
}
