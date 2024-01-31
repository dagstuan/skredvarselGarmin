using Microsoft.Extensions.Caching.Memory;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public class GarminAuthenticationService(
    SkredvarselDbContext dbContext,
    IMemoryCache memoryCache) : IGarminAuthenticationService
{
    public User? GetUserForWatchOrNull(string watchId) => dbContext.GetUserForWatchOrNull(watchId);

    public bool DoesWatchHaveActiveSubscription(string watchId)
    {
        var cacheKey = $"DoesWatchHaveActiveAgreement_{watchId}";

        if (memoryCache.TryGetValue<bool>(cacheKey, out var valueFromCache))
        {
            return valueFromCache;
        }

        var userForWatch = dbContext.GetUserForWatchOrNull(watchId);

        if (userForWatch != null && dbContext.DoesUserHaveActiveSubscription(userForWatch.Id))
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromHours(3));

            memoryCache.Set(cacheKey, true, cacheEntryOptions);

            return true;
        }

        return false;
    }
}
