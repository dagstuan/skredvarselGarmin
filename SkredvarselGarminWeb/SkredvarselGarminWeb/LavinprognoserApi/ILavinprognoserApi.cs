using System.Text.Json;

using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public interface ILavinprognoserApi
{
    Task<IEnumerable<WfsFeature<JsonElement>>> GetAllLocationPolygons();
    Task<IEnumerable<WfsFeature<LavinprognoserLocation>>> GetLocationPolygons();
    Task<IEnumerable<LavinprognoserDetailedWarning>> GetDetailedWarningsByArea(int areaId, DateOnly from, DateOnly to);
}
