using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class LavinprognoserApiRouteBuilderExtensions
{
    public static void MapLavinprognoserApiEndpoints(this IEndpointRouteBuilder app, AuthOptions authOptions)
    {
        var simpleGet = app.MapGet("/api/se/simpleWarningsByRegion/{areaId}/{from}/{to}", async (
            int areaId,
            DateOnly from,
            DateOnly to,
            ILavinprognoserWarningService lavinprognoserWarningService) =>
        {
            var warnings = await lavinprognoserWarningService.GetDetailedWarningsByArea(areaId, from, to);
            return Results.Ok(warnings.Select(w => w.ToSimpleAvalancheWarning()));
        });

        var detailedGet = app.MapGet("/api/se/detailedWarningsByRegion/{areaId}/{from}/{to}", async (
            int areaId,
            DateOnly from,
            DateOnly to,
            ILavinprognoserWarningService lavinprognoserWarningService) =>
        {
            var warnings = await lavinprognoserWarningService.GetDetailedWarningsByArea(areaId, from, to);
            return Results.Ok(warnings.Select(w => w.ToDetailedAvalancheWarning()));
        });

        if (authOptions.UseWatchAuthorization)
        {
            simpleGet.RequireAuthorization("Garmin");
            detailedGet.RequireAuthorization("Garmin");
        }
    }
}
