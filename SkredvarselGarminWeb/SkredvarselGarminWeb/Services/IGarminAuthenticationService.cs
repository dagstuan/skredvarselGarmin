namespace SkredvarselGarminWeb.Services;

public interface IGarminAuthenticationService
{
    bool DoesWatchHaveActiveAgreement(string watchId);
}
