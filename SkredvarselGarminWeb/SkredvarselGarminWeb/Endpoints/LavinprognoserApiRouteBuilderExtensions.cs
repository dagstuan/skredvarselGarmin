using System.Text.Json;

using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class LavinprognoserApiRouteBuilderExtensions
{
    public static void MapLavinprognoserApiEndpoints(this IEndpointRouteBuilder app, AuthOptions authOptions)
    {
        var areasGet = app.MapGet("/api/se/areas", async (ILavinprognoserApi lavinprognoserApi) =>
        {
            var areas = await lavinprognoserApi.GetAllLocationPolygons();
            return Results.Ok(areas.Select(MapAreaSummary));
        });

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
            areasGet.RequireAuthorization("Garmin");
            simpleGet.RequireAuthorization("Garmin");
            detailedGet.RequireAuthorization("Garmin");
        }
    }

    private static SwedishAreaSummary MapAreaSummary(LavinprognoserApi.Models.WfsFeature<JsonElement> area)
    {
        var properties = area.Properties;

        return new SwedishAreaSummary(
            Id: properties.GetProperty("id").GetInt32(),
            Name: properties.GetProperty("label").GetString() ?? string.Empty,
            ParentId: properties.TryGetProperty("parent_id", out var parentId) && parentId.ValueKind != JsonValueKind.Null
                ? parentId.GetInt32()
                : null);
    }

    private sealed record SwedishAreaSummary(int Id, string Name, int? ParentId);
}
