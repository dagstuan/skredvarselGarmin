using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Services;

public interface IVarsomWarningService
{
    Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(int regionId, string langKey, DateOnly from, DateOnly to);
}
