using NetTopologySuite.Features;
using NetTopologySuite.Geometries;
using NetTopologySuite.IO;

using Newtonsoft.Json;

using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Endpoints;

public static class ForecastAreaEndpointsRouteBuilderExtensions
{
    public static void MapForecastAreaEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/forecastAreas/closestTypeAArea/{latitude}/{longitude}", (IForecastAreaService forecastAreaService, double latitude, double longitude) =>
        {
            return forecastAreaService.GetClosestTypeAForecastAreaForLocation(latitude, longitude);
        });

        app.MapPost("/api/forecastAreas/replace", (IForecastAreaService forecastAreaService, IFormFile file) =>
        {
            var serializer = GeoJsonSerializer.Create(new GeometryFactory(new PrecisionModel(), 25833));

            using var streamReader = new StreamReader(file.OpenReadStream());
            using var jsonReader = new JsonTextReader(streamReader);

            var geometry = serializer.Deserialize<FeatureCollection>(jsonReader);

            return geometry == null ?
                Results.BadRequest("Invalid GeoJSON") :
                Results.Ok(forecastAreaService.ReplaceForecastAreas(geometry));
        }).DisableAntiforgery().RequireAuthorization("Admin");
    }
}
