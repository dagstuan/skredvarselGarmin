using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class ChargeSummary
{
    [JsonPropertyName("captured")]
    public int Captured { get; set; }

    [JsonPropertyName("refunded")]
    public int Refunded { get; set; }

    [JsonPropertyName("cancelled")]
    public int Cancelled { get; set; }
}
