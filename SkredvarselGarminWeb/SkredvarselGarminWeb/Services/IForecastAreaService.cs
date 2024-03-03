using NetTopologySuite.Features;

namespace SkredvarselGarminWeb.Services;

public interface IForecastAreaService
{
    int GetClosestTypeAForecastAreaForLocation(double latitude, double longitude);
    int ReplaceForecastAreas(FeatureCollection geometry);
}
