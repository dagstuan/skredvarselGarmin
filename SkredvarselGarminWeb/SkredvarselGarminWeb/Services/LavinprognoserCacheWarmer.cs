using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.LavinprognoserApi;

namespace SkredvarselGarminWeb.Services;

// Runs in-process on every instance, since the forecasts are cached in each instance's IMemoryCache.
public class LavinprognoserCacheWarmer(
    IServiceScopeFactory serviceScopeFactory,
    IDateTimeNowProvider dateTimeNowProvider,
    ILogger<LavinprognoserCacheWarmer> logger) : BackgroundService
{
    // Shorter than the 1 hour cache expiration, so cached forecasts are replaced before they expire
    // and requests never have to wait for Lavinprognoser.
    private static readonly TimeSpan Interval = TimeSpan.FromMinutes(50);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(Interval);

        do
        {
            await RefreshForecasts(stoppingToken);
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    private async Task RefreshForecasts(CancellationToken cancellationToken)
    {
        using var scope = serviceScopeFactory.CreateScope();
        var lavinprognoserApi = scope.ServiceProvider.GetRequiredService<ILavinprognoserApi>();

        var today = DateOnly.FromDateTime(dateTimeNowProvider.UtcNow);
        var from = today.AddDays(-2);
        var to = today.AddDays(3);

        foreach (var areaId in SwedishForecastAreaRegistry.AreasById.Keys)
        {
            if (cancellationToken.IsCancellationRequested) return;

            try
            {
                await lavinprognoserApi.RefreshForecastsByArea(areaId, from, to);
            }
            catch (Exception e)
            {
                logger.LogError(e, "Failed to refresh Lavinprognoser forecasts for area {areaId}.", areaId);
            }
        }
    }
}
