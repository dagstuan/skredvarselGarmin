using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Services;

public interface ILavinprognoserWarningService
{
    Task<IEnumerable<LavinprognoserDetailedWarning>> GetDetailedWarningsByArea(int areaId, DateOnly from, DateOnly to);
}
