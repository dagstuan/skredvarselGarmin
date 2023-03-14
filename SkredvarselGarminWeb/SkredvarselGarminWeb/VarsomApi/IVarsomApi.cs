using Refit;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public interface IVarsomApi
{
    [Get("/avalancheWarningByRegion/Simple/{regionId}/{langKey}/{from}/{to}")]
    Task<IEnumerable<VarsomSimpleAvalancheWarning>> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);

    [Get("/avalancheWarningByRegion/Detail/{regionId}/{langKey}/{from}/{to}")]
    Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);
}
