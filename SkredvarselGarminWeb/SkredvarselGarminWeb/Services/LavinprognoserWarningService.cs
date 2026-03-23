using System.Collections.Concurrent;

using Microsoft.Extensions.Caching.Memory;

using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Services;

public class LavinprognoserWarningService(ILavinprognoserApi lavinprognoserApi, IMemoryCache memoryCache) : ILavinprognoserWarningService
{
    private static readonly ConcurrentDictionary<string, SemaphoreSlim> InFlightLocks = new();

    public async Task<IEnumerable<LavinprognoserDetailedWarning>> GetDetailedWarningsByArea(int areaId, DateOnly from, DateOnly to)
    {
        var cacheKey = $"LavinprognoserWarnings_{areaId}_{from:yyyy-MM-dd}_{to:yyyy-MM-dd}";

        if (memoryCache.TryGetValue<IEnumerable<LavinprognoserDetailedWarning>>(cacheKey, out var cachedWarnings))
        {
            return cachedWarnings ?? [];
        }

        var semaphore = InFlightLocks.GetOrAdd(cacheKey, _ => new SemaphoreSlim(1, 1));
        await semaphore.WaitAsync();

        try
        {
            if (memoryCache.TryGetValue(cacheKey, out cachedWarnings))
            {
                return cachedWarnings ?? [];
            }

            var warnings = await lavinprognoserApi.GetDetailedWarningsByArea(areaId, from, to);
            memoryCache.Set(cacheKey, warnings, new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1)
            });

            return warnings;
        }
        finally
        {
            semaphore.Release();

            if (semaphore.CurrentCount == 1)
            {
                InFlightLocks.TryRemove(new KeyValuePair<string, SemaphoreSlim>(cacheKey, semaphore));
            }
        }
    }
}
