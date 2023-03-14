using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class ChargeEvent
{
    [JsonPropertyName("occurred")]
    public DateTime Occurred { get; set; } = DateTime.MinValue;

    [JsonPropertyName("event")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public ChargeEventEvent Event { get; set; } = ChargeEventEvent.CREATE;

    [JsonPropertyName("amount")]
    public int Amount { get; set; } = 0;

    [JsonPropertyName("idempotencyKey")]
    public string IdempotencyKey { get; set; } = string.Empty;

    [JsonPropertyName("success")]
    public bool Success { get; set; } = false;
}
