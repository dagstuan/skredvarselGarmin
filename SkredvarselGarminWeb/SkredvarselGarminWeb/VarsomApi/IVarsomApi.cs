using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public interface IVarsomApi
{
    Task<VarsomSimpleAvalancheWarning[]> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);
    Task<VarsomDetailedAvalancheWarning?> GetDetailedWarningByRegion(string regionId, string langKey, DateOnly date);
}
