using System.Text.Json;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.VarsomApi;

public class VarsomApi : IVarsomApi
{
    private const string BaseUrl = "https://api01.nve.no/hydrology/forecast/avalanche/v6.2.1/api";

    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<VarsomApi> _logger;

    public VarsomApi(IHttpClientFactory httpClientFactory, ILogger<VarsomApi> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<IEnumerable<VarsomSimpleAvalancheWarning>> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to)
    {
        using var client = _httpClientFactory.CreateClient();

        try
        {
            var url = $"{BaseUrl}/avalancheWarningByRegion/Simple/{regionId}/{langKey}/{from:yyyy-MM-dd}/{to:yyyy-MM-dd}";
            var warnings = await client.GetFromJsonAsync<IEnumerable<VarsomSimpleAvalancheWarning>>(
                url,
                new JsonSerializerOptions(JsonSerializerDefaults.Web));

            return warnings ?? new List<VarsomSimpleAvalancheWarning>();
        }
        catch (Exception ex)
        {
            _logger.LogError("Error getting warnings by region: {Error}", ex);
        }

        return new List<VarsomSimpleAvalancheWarning>();
    }

    public async Task<IEnumerable<VarsomDetailedAvalancheWarning>> GetDetailedWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to)
    {
        using var client = _httpClientFactory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(30);

        try
        {
            var url = $"{BaseUrl}/avalancheWarningByRegion/Detail/{regionId}/{langKey}/{from:yyyy-MM-dd}/{to:yyyy-MM-dd}";
            var warnings = await client.GetFromJsonAsync<IEnumerable<VarsomDetailedAvalancheWarning>>(
                url,
                new JsonSerializerOptions(JsonSerializerDefaults.Web));

            return warnings ?? new List<VarsomDetailedAvalancheWarning>();
        }
        catch (Exception ex)
        {
            _logger.LogError("Error getting warnings by region: {Error}", ex);
        }

        return new List<VarsomDetailedAvalancheWarning>();
    }
}
