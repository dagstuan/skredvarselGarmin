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

    public async Task<VarsomAvalancheWarning[]> GetWarningsByRegion(string regionId, string langKey, DateOnly from, DateOnly to)
    {
        using var client = _httpClientFactory.CreateClient();

        try
        {
            var url = $"{BaseUrl}/avalancheWarningByRegion/Simple/{regionId}/{langKey}/{from:yyyy-MM-dd}/{to:yyyy-MM-dd}";
            // Make HTTP GET request
            // Parse JSON response deserialize into Todo types
            var warnings = await client.GetFromJsonAsync<VarsomAvalancheWarning[]>(
                url,
                new JsonSerializerOptions(JsonSerializerDefaults.Web));

            return warnings ?? Array.Empty<VarsomAvalancheWarning>();
        }
        catch (Exception ex)
        {
            _logger.LogError("Error getting warnings by region: {Error}", ex);
        }

        return Array.Empty<VarsomAvalancheWarning>();
    }
}
