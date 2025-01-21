using Microsoft.EntityFrameworkCore;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public class WatchService(SkredvarselDbContext dbContext) : IWatchService
{
    public WatchAddRequest? GetWatchAddRequest(string watchAddKey)
    {
        return dbContext.WatchAddRequests.FirstOrDefault(r => EF.Functions.ILike(r.Key, watchAddKey));
    }

    public void AddWatch(WatchAddRequest watchAddRequest, string userId)
    {
        dbContext.Watches.Add(new Watch
        {
            Id = watchAddRequest.WatchId,
            PartNumber = watchAddRequest.PartNumber,
            UserId = userId
        });

        dbContext.WatchAddRequests.Remove(watchAddRequest);
        dbContext.SaveChanges();
    }
}
