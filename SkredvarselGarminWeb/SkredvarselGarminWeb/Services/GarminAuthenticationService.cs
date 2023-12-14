using Microsoft.Extensions.Caching.Memory;
using SkredvarselGarminWeb.Database;

namespace SkredvarselGarminWeb.Services;

public class GarminAuthenticationService(
    SkredvarselDbContext dbContext,
    IMemoryCache memoryCache) : IGarminAuthenticationService
{
    public bool DoesWatchHaveActiveAgreement(string watchId)
    {
        var cacheKey = $"DoesWatchHaveActiveAgreement_{watchId}";

        if (memoryCache.TryGetValue<bool>(cacheKey, out var valueFromCache))
        {
            return valueFromCache;
        }

        var userForWatch = dbContext.GetUserForWatchOrNull(watchId);

        if (userForWatch != null && dbContext.DoesUserHaveActiveAgreement(userForWatch.Id))
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromHours(3));

            memoryCache.Set(cacheKey, true, cacheEntryOptions);

            return true;
        }

        return false;
    }
}
