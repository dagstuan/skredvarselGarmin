using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Pricing
{
    [JsonPropertyName("type")]
    public string Type { get; } = "LEGACY";

    [JsonPropertyName("amount")]
    public required int Amount { get; init; }

    [JsonPropertyName("currency")]
    public string Currency { get; } = "NOK";
}
