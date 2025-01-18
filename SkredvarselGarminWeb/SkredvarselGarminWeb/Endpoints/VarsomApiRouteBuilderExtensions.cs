using Microsoft.Extensions.Caching.Memory;

using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints;

public static class VarsomApiRouteBuilderExtensions
{
    private static async Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetVarsomWarnings(
        int regionId,
        string langKey,
        DateOnly from,
        DateOnly to,
        IVarsomApi varsomApi,
        IMemoryCache memoryCache)
    {
        var cacheKey = $"VarsomWarnings_{regionId}_{langKey}_{from:yyyy-MM-dd}_{to:yyyy-MM-dd}";

        return await memoryCache.GetOrCreateAsync(cacheKey, async (cacheEntry) =>
        {
            cacheEntry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);

            return await varsomApi.GetDetailedWarningsByRegion(regionId, langKey, from, to);
        }) ?? [];
    }

    public static void MapVarsomApiEndpoints(this IEndpointRouteBuilder app, AuthOptions authOptions)
    {
        var simpleGet = app.MapGet("/api/simpleWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            int regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var varsomWarnings = await GetVarsomWarnings(regionId, langKey, from, to, varsomApi, memoryCache);

            return varsomWarnings.Select(vw => vw.ToSimpleAvalancheWarning(langKey));
        });

        var detailedGet = app.MapGet("/api/detailedWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            int regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var varsomWarnings = await GetVarsomWarnings(regionId, langKey, from, to, varsomApi, memoryCache);

            return varsomWarnings.Select(vw => vw.ToDetailedAvalancheWarning(langKey));
        });

        var simpleGetByLocation = app.MapGet("/api/simpleWarningsByLocation/{latitude}/{longitude}/{langKey}/{from}/{to}", async (
            double latitude,
            double longitude,
            string langKey,
            DateOnly from,
            DateOnly to,
            IForecastAreaService forecastAreaService,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var regionId = forecastAreaService.GetClosestTypeAForecastAreaForLocation(latitude, longitude);

            var varsomWarnings = await GetVarsomWarnings(regionId, langKey, from, to, varsomApi, memoryCache);

            return new SimpleWarningsForLocationResponse
            {
                RegionId = regionId,
                Warnings = varsomWarnings.Select(vw => vw.ToSimpleAvalancheWarning(langKey))
            };
        });

        if (authOptions.UseWatchAuthorization)
        {
            simpleGet.RequireAuthorization("Garmin");
            detailedGet.RequireAuthorization("Garmin");
            simpleGetByLocation.RequireAuthorization("Garmin");
        }
    }
}
