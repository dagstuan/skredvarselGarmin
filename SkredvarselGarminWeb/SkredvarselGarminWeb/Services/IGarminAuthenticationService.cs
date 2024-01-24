using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IGarminAuthenticationService
{
    User? GetUserForWatchOrNull(string watchId);
    bool DoesWatchHaveActiveSubscription(string watchId);
}
