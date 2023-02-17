using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public interface IVarsomApi
{
    Task<VarsomAvalancheWarning[]> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to);
}
