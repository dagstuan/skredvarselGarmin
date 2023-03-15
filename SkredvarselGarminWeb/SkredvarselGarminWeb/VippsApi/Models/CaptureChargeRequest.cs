using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class CaptureChargeRequest
{
    [JsonPropertyName("amount")]
    public required int Amount { get; init; }

    [JsonPropertyName("description")]
    public required string Description { get; init; }
}
