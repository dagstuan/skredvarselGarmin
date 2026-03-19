using Microsoft.Extensions.Caching.Memory;

using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Services;

public class LavinprognoserWarningService(ILavinprognoserApi lavinprognoserApi, IMemoryCache memoryCache) : ILavinprognoserWarningService
{
    public async Task<IEnumerable<LavinprognoserDetailedWarning>> GetDetailedWarningsByArea(int areaId, DateOnly from, DateOnly to)
    {
        var cacheKey = $"LavinprognoserWarnings_{areaId}_{from:yyyy-MM-dd}_{to:yyyy-MM-dd}";

        return await memoryCache.GetOrCreateAsync(cacheKey, async cacheEntry =>
        {
            cacheEntry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
            return await lavinprognoserApi.GetDetailedWarningsByArea(areaId, from, to);
        }) ?? [];
    }
}
