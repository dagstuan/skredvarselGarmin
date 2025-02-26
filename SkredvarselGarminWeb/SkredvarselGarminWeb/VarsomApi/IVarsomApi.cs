using Refit;

using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public interface IVarsomApi
{
    [Get("/AvalancheWarningByRegion/Detail/{regionId}/{langKey}/{from}/{to}")]
    Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(int regionId, string langKey, DateOnly from, DateOnly to);
}
