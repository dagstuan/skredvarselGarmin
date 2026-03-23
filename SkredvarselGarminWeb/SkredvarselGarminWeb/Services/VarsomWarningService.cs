using Microsoft.Extensions.Caching.Memory;

using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Services;

public class VarsomWarningService(IVarsomApi varsomApi, IMemoryCache memoryCache) : IVarsomWarningService
{
    public async Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(int regionId, string langKey, DateOnly from, DateOnly to)
    {
        var cacheKey = $"VarsomWarnings_{regionId}_{langKey}_{from:yyyy-MM-dd}_{to:yyyy-MM-dd}";

        return await memoryCache.GetOrCreateAsync(cacheKey, async cacheEntry =>
        {
            cacheEntry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
            return await varsomApi.GetDetailedWarningsByRegion(regionId, langKey, from, to);
        }) ?? [];
    }
}
