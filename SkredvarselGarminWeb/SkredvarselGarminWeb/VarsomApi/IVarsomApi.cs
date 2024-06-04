using Refit;

using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public interface IVarsomApi
{
    [Get("/avalancheWarningByRegion/Detail/{regionId}/{langKey}/{from}/{to}")]
    Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);
}
