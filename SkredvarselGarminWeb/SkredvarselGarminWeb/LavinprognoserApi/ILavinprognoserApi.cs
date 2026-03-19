using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public interface ILavinprognoserApi
{
    Task<IEnumerable<WfsFeature<LavinprognoserLocation>>> GetLocationPolygons();
    Task<IEnumerable<LavinprognoserDetailedWarning>> GetDetailedWarningsByArea(int areaId, DateOnly from, DateOnly to);
}
