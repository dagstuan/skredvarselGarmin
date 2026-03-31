using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class LocationApiRouteBuilderExtensions
{
    public static void MapLocationApiEndpoints(this IEndpointRouteBuilder app, AuthOptions authOptions)
    {
        var simpleGetByLocation = app.MapGet("/api/simpleWarningsByLocation/{latitude}/{longitude}/{langKey}/{from}/{to}", async (
            double latitude,
            double longitude,
            string langKey,
            DateOnly from,
            DateOnly to,
            bool? includeSwedishAreas,
            IForecastAreaService forecastAreaService,
            IVarsomWarningService varsomWarningService,
            ILavinprognoserWarningService lavinprognoserWarningService) =>
        {
            var (regionId, country) = forecastAreaService.GetClosestTypeAForecastAreaForLocation(latitude, longitude, includeSwedishAreas ?? false);

            IEnumerable<SimpleAvalancheWarning> simpleWarnings;
            if (country == Country.SE)
            {
                var seWarnings = await lavinprognoserWarningService.GetDetailedWarningsByArea(regionId, from, to);
                simpleWarnings = seWarnings.Select(w => w.ToSimpleAvalancheWarning());
            }
            else
            {
                var noWarnings = await varsomWarningService.GetDetailedWarningsByRegion(regionId, langKey, from, to);
                simpleWarnings = noWarnings.Select(w => w.ToSimpleAvalancheWarning(langKey));
            }

            return Results.Ok(new SimpleWarningsForLocationResponse
            {
                RegionId = country == Country.SE ? $"se_{regionId}" : regionId.ToString(),
                Warnings = simpleWarnings,
            });
        });

        var detailedGetByLocation = app.MapGet("/api/detailedWarningsByLocation/{latitude}/{longitude}/{langKey}/{from}/{to}", async (
            double latitude,
            double longitude,
            string langKey,
            DateOnly from,
            DateOnly to,
            IForecastAreaService forecastAreaService,
            IVarsomWarningService varsomWarningService,
            ILavinprognoserWarningService lavinprognoserWarningService) =>
        {
            var (regionId, country) = forecastAreaService.GetClosestTypeAForecastAreaForLocation(latitude, longitude, true);

            IEnumerable<DetailedAvalancheWarning> detailedWarnings;
            if (country == Country.SE)
            {
                var seWarnings = await lavinprognoserWarningService.GetDetailedWarningsByArea(regionId, from, to);
                detailedWarnings = seWarnings.Select(w => w.ToDetailedAvalancheWarning());
            }
            else
            {
                var noWarnings = await varsomWarningService.GetDetailedWarningsByRegion(regionId, langKey, from, to);
                detailedWarnings = noWarnings.Select(w => w.ToDetailedAvalancheWarning(langKey));
            }

            return Results.Ok(new DetailedWarningsForLocationResponse
            {
                RegionId = country == Country.SE ? $"se_{regionId}" : regionId.ToString(),
                Warnings = detailedWarnings,
            });
        });

        var regionByLocation = app.MapGet("/api/regionByLocation/{latitude}/{longitude}", (
            double latitude,
            double longitude,
            bool? includeSwedishAreas,
            IForecastAreaService forecastAreaService) =>
        {
            var (regionId, country) = forecastAreaService.GetClosestTypeAForecastAreaForLocation(latitude, longitude, includeSwedishAreas ?? false);

            return Results.Ok(new
            {
                RegionId = country == Country.SE ? $"se_{regionId}" : regionId.ToString(),
            });
        });

        if (authOptions.UseWatchAuthorization)
        {
            simpleGetByLocation.RequireAuthorization("Garmin");
            detailedGetByLocation.RequireAuthorization("Garmin");
            regionByLocation.RequireAuthorization("Garmin");
        }
    }
}
