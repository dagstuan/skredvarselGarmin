using Microsoft.Extensions.Caching.Memory;

using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints;

public static class VarsomApiRouteBuilderExtensions
{
    private static async Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetVarsomWarnings(
        string regionId,
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
            string regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var varsomWarnings = await GetVarsomWarnings(regionId, langKey, from, to, varsomApi, memoryCache);

            return varsomWarnings.Select(vw => vw.ToSimpleAvalancheWarning());
        });

        var detailedGet = app.MapGet("/api/detailedWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            string regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var varsomWarnings = await GetVarsomWarnings(regionId, langKey, from, to, varsomApi, memoryCache);

            return varsomWarnings.Select(vw => vw.ToDetailedAvalancheWarning());
        });

        if (authOptions.UseWatchAuthorization)
        {
            simpleGet.RequireAuthorization("Garmin");
            detailedGet.RequireAuthorization("Garmin");
        }
    }
}
