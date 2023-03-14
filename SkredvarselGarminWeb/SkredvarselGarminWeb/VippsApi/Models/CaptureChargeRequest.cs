using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class CaptureChargeRequest
{
    [JsonPropertyName("amount")]
    public int Amount { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;
}
