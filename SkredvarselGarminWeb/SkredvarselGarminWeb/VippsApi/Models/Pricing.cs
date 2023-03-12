using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Pricing
{
    [JsonPropertyName("type")]
    public string Type { get; set; } = string.Empty;

    [JsonPropertyName("amount")]
    public int Amount { get; set; } = 0;

    [JsonPropertyName("currency")]
    public string Currency { get; set; } = string.Empty;
}
