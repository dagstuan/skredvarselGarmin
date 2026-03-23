using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class VarsomApiRouteBuilderExtensions
{
    public static void MapVarsomApiEndpoints(this IEndpointRouteBuilder app, AuthOptions authOptions)
    {
        var simpleGet = app.MapGet("/api/simpleWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            int regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomWarningService varsomWarningService) =>
        {
            var varsomWarnings = await varsomWarningService.GetDetailedWarningsByRegion(regionId, langKey, from, to);

            return varsomWarnings.Select(vw => vw.ToSimpleAvalancheWarning(langKey));
        });

        var detailedGet = app.MapGet("/api/detailedWarningsByRegion/{regionId}/{langKey}/{from}/{to}", async (
            int regionId,
            string langKey,
            DateOnly from,
            DateOnly to,
            IVarsomWarningService varsomWarningService) =>
        {
            var varsomWarnings = await varsomWarningService.GetDetailedWarningsByRegion(regionId, langKey, from, to);

            return varsomWarnings.Select(vw => vw.ToDetailedAvalancheWarning(langKey));
        });

        if (authOptions.UseWatchAuthorization)
        {
            simpleGet.RequireAuthorization("Garmin");
            detailedGet.RequireAuthorization("Garmin");
        }
    }
}
