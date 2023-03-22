using Microsoft.Extensions.Caching.Memory;
using SkredvarselGarminWeb.Database;

namespace SkredvarselGarminWeb.Services;

public class GarminAuthenticationService : IGarminAuthenticationService
{
    private readonly SkredvarselDbContext _dbContext;
    private readonly IMemoryCache _memoryCache;

    public GarminAuthenticationService(SkredvarselDbContext dbContext, IMemoryCache memoryCache)
    {
        _dbContext = dbContext;
        _memoryCache = memoryCache;
    }

    public bool DoesWatchHaveActiveAgreement(string watchId)
    {
        var cacheKey = $"DoesWatchHaveActiveAgreement_{watchId}";

        if (_memoryCache.TryGetValue<bool>(cacheKey, out var valueFromCache))
        {
            return valueFromCache;
        }

        var userForWatch = _dbContext.GetUserForWatchOrNull(watchId);

        if (userForWatch != null && _dbContext.DoesUserHaveActiveAgreement(userForWatch.Id))
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromHours(3));

            _memoryCache.Set(cacheKey, true, cacheEntryOptions);

            return true;
        }

        return false;
    }
}
