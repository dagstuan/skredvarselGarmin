using NetTopologySuite.Features;
using NetTopologySuite.Geometries;

using ProjNet.CoordinateSystems;
using ProjNet.CoordinateSystems.Transformations;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public class ForecastAreaService(SkredvarselDbContext dbContext) : IForecastAreaService
{
    public int GetClosestTypeAForecastAreaForLocation(double latitude, double longitude)
    {
        var sourceCS = GeographicCoordinateSystem.WGS84;
        var targetCS = ProjectedCoordinateSystem.WGS84_UTM(33, true);
        var ctfac = new CoordinateTransformationFactory();
        var trans = ctfac.CreateFromCoordinateSystems(sourceCS, targetCS);

        var transformed = trans.MathTransform.Transform([longitude, latitude]);

        var point = new Point(transformed[0], transformed[1]) { SRID = 25833 };

        return dbContext.ForecastAreas
            .Where(a => a.RegionType == 'A')
            .Select(a => new { a.Id, Distance = a.Area.Distance(point) })
            .OrderBy(a => a.Distance)
            .First().Id;
    }

    public int ReplaceForecastAreas(FeatureCollection geometry)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        dbContext.ForecastAreas.RemoveRange(dbContext.ForecastAreas);

        var forecastAreas = geometry.Select(g => new ForecastArea
        {
            Id = Convert.ToInt32(g.Attributes["omradeID"]),
            Name = g.Attributes["omradeNavn"].ToString()!,
            RegionType = g.Attributes["regionType"].ToString()![0],
            Area = (Polygon)g.Geometry
        }).ToList();

        dbContext.ForecastAreas.AddRange(forecastAreas);
        dbContext.SaveChanges();

        transaction.Commit();

        return forecastAreas.Count;
    }
}
