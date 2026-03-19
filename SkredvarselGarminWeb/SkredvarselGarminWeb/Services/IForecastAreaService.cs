using NetTopologySuite.Features;

using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IForecastAreaService
{
    (int Id, Country Country) GetClosestTypeAForecastAreaForLocation(double latitude, double longitude, bool includeSwedishAreas = true);
    int ReplaceForecastAreas(FeatureCollection geometry);
}
