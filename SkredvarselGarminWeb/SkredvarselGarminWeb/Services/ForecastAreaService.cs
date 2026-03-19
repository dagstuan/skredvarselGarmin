using NetTopologySuite.Features;
using NetTopologySuite.Geometries;

using ProjNet.CoordinateSystems;
using ProjNet.CoordinateSystems.Transformations;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public class ForecastAreaService(SkredvarselDbContext dbContext) : IForecastAreaService
{
    public (int Id, Country Country) GetClosestTypeAForecastAreaForLocation(double latitude, double longitude, bool includeSwedishAreas = true)
    {
        var sourceCS = GeographicCoordinateSystem.WGS84;
        var targetCS = ProjectedCoordinateSystem.WGS84_UTM(33, true);
        var ctfac = new CoordinateTransformationFactory();
        var trans = ctfac.CreateFromCoordinateSystems(sourceCS, targetCS);

        var transformed = trans.MathTransform.Transform([longitude, latitude]);

        var point = new Point(transformed[0], transformed[1]) { SRID = 25833 };

        var area = dbContext.ForecastAreas
            .Where(a => a.RegionType == 'A')
            .Where(a => includeSwedishAreas || a.Country != nameof(Country.SE))
            .Select(a => new { a.Id, a.Country, Distance = a.Area.Distance(point) })
            .OrderBy(a => a.Distance)
            .First();

        return (area.Id, Enum.Parse<Country>(area.Country));
    }

    public int ReplaceForecastAreas(FeatureCollection geometry)
    {
        using var transaction = dbContext.Database.BeginTransaction();

        dbContext.ForecastAreas.RemoveRange(dbContext.ForecastAreas.Where(a => a.Country == nameof(Country.NO)));

        var forecastAreas = geometry.Select(g =>
        {
            var polygon = (Polygon)g.Geometry;
            polygon.SRID = 25833;

            return new ForecastArea
            {
                Id = Convert.ToInt32(g.Attributes["omradeID"]),
                Name = g.Attributes["omradeNavn"].ToString()!,
                RegionType = g.Attributes["regionType"].ToString()![0],
                Country = nameof(Country.NO),
                Area = polygon
            };
        }).ToList();

        dbContext.ForecastAreas.AddRange(forecastAreas);
        dbContext.SaveChanges();

        transaction.Commit();

        return forecastAreas.Count;
    }
}
