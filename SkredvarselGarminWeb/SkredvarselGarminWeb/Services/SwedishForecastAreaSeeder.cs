using NetTopologySuite.Geometries;

using ProjNet.CoordinateSystems;
using ProjNet.CoordinateSystems.Transformations;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Services;

public class SwedishForecastAreaSeeder(SkredvarselDbContext dbContext, ILavinprognoserApi lavinprognoserApi) : ISwedishForecastAreaSeeder
{
    private const string Sweref99TmWkt = """
PROJCS["SWEREF99 TM",
    GEOGCS["SWEREF99",
        DATUM["SWEREF99",SPHEROID["GRS 1980",6378137,298.257222101]],
        PRIMEM["Greenwich",0],
        UNIT["degree",0.0174532925199433]],
    PROJECTION["Transverse_Mercator"],
    PARAMETER["latitude_of_origin",0],
    PARAMETER["central_meridian",15],
    PARAMETER["scale_factor",0.9996],
    PARAMETER["false_easting",500000],
    PARAMETER["false_northing",0],
    UNIT["metre",1]]
""";

    // SWEREF99TM (EPSG:3006) → UTM zone 33N (EPSG:25833)
    private static readonly GeoAPI.CoordinateSystems.Transformations.IMathTransform Sweref99TmToUtm33N =
        new CoordinateTransformationFactory()
            .CreateFromCoordinateSystems(
                new CoordinateSystemFactory().CreateFromWkt(Sweref99TmWkt),
                ProjectedCoordinateSystem.WGS84_UTM(33, true))
            .MathTransform;

    private static readonly GeometryFactory GeometryFactory25833 = new(new PrecisionModel(), 25833);

    public async Task SeedAsync()
    {
        var features = await lavinprognoserApi.GetLocationPolygons();
        var forecastAreas = features
            .Where(feature => feature.Geometry != null)
            .Where(feature => SwedishForecastAreaRegistry.ContainsAreaId(feature.Properties.Id))
            .Select(BuildForecastArea)
            .ToList();

        using var transaction = await dbContext.Database.BeginTransactionAsync();

        dbContext.ForecastAreas.RemoveRange(dbContext.ForecastAreas.Where(area => area.Country == nameof(Country.SE)));
        await dbContext.SaveChangesAsync();

        dbContext.ForecastAreas.AddRange(forecastAreas);

        await dbContext.SaveChangesAsync();
        await transaction.CommitAsync();
    }

    private static ForecastArea BuildForecastArea(WfsFeature<LavinprognoserLocation> feature)
    {
        return new ForecastArea
        {
            Id = feature.Properties.Id,
            Name = SwedishForecastAreaRegistry.GetName(feature.Properties.Id) ?? string.Empty,
            RegionType = 'A',
            Country = nameof(Country.SE),
            Area = CreatePolygon(feature.Geometry!),
        };
    }

    private static Polygon CreatePolygon(WfsGeometry geometry)
    {
        var reprojectedRings = geometry.Coordinates
            .Select(ring => ring
                .Select(coordinate => Sweref99TmToUtm33N.Transform(coordinate))
                .Select(coordinate => new Coordinate(coordinate[0], coordinate[1]))
                .ToArray())
            .ToArray();

        var shell = GeometryFactory25833.CreateLinearRing(reprojectedRings[0]);
        var holes = reprojectedRings.Skip(1)
            .Select(GeometryFactory25833.CreateLinearRing)
            .ToArray();

        return GeometryFactory25833.CreatePolygon(shell, holes);
    }
}
