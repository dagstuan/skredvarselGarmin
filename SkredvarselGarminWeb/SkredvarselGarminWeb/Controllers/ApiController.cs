using Microsoft.AspNetCore.Mvc;
using SkredvarselGarminWeb.Models;
using SkredvarselGarminWeb.VarsomApi;

namespace SkredvarselGarminWeb.Controllers;

[ApiController]
[Route("[controller]")]
public class ApiController
{
    private readonly IVarsomApi _varsomApi;

    public ApiController(IVarsomApi varsomApi)
    {
        _varsomApi = varsomApi;
    }

    [HttpGet("simpleWarningsByRegion/{regionId}/{langKey}/{from}/{to}")]
    public async Task<IEnumerable<SimpleAvalancheWarning>> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to)
    {
        var warnings = await _varsomApi.GetWarningsByRegion(regionId, langKey, from, to);

        return warnings.Select(w => new SimpleAvalancheWarning
        {
            DangerLevel = w.DangerLevel,
            ValidFrom = w.ValidFrom,
            ValidTo = w.ValidTo
        });
    }
}
