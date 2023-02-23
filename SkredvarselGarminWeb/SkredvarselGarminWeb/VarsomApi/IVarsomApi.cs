using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public interface IVarsomApi
{
    Task<IEnumerable<VarsomSimpleAvalancheWarning>> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);
    Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);
}
