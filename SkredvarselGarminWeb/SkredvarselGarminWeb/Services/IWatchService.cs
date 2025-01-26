using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IWatchService
{
    WatchAddRequest? GetWatchAddRequest(string watchAddKey);
    void AddWatch(WatchAddRequest watchAddRequest, string userId);
}
