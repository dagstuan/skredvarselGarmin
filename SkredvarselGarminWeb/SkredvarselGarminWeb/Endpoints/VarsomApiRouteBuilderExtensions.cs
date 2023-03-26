using Microsoft.Extensions.Caching.Memory;
using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.VarsomApi;

namespace SkredvarselGarminWeb.Endpoints;

public static class VarsomApiRouteBuilderExtensions
{
    public static void MapVarsomApiEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/simpleWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            string regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var cacheKey = $"SimpleWarnings_{regionId}_{langKey}_{from:yyyy-MM-dd}_{to:yyyy-MM-dd}";
            return await memoryCache.GetOrCreateAsync(cacheKey, async (cacheEntry) =>
            {
                cacheEntry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);

                var warnings = await varsomApi.GetWarningsByRegion(regionId, langKey, from, to);

                return warnings.Select(w => new SimpleAvalancheWarning
                {
                    DangerLevel = int.Parse(w.DangerLevel),
                    Validity = new DateTime[] {
                        w.ValidFrom,
                        w.ValidTo
                    }
                });
            });
        }).RequireAuthorization("Garmin");

        app.MapGet("/api/detailedWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            string regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomApi varsomApi,
            IMemoryCache memoryCache) =>
        {
            var cacheKey = $"DetailedWarnings_{regionId}_{langKey}_{from:yyyy-MM-dd}_{to:yyyy-MM-dd}";

            return await memoryCache.GetOrCreateAsync(cacheKey, async (cacheEntry) =>
            {
                cacheEntry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);

                var warnings = await varsomApi.GetDetailedWarningsByRegion(regionId, langKey, from, to);

                return warnings.Select(w => w.ToDetailedAvalancheWarning());
            });
        }).RequireAuthorization("Garmin");
    }
}
