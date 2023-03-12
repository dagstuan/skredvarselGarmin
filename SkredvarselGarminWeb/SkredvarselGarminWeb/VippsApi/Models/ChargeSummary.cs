using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class ChargeSummary
{
    [JsonPropertyName("captured")]
    public required int Captured { get; init; }

    [JsonPropertyName("refunded")]
    public required int Refunded { get; init; }

    [JsonPropertyName("cancelled")]
    public required int Cancelled { get; init; }
}
