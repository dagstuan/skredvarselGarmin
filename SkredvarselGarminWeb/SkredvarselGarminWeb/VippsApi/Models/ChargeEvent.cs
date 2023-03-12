using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class ChargeEvent
{
    [JsonPropertyName("occurred")]
    public required DateTime Occurred { get; init; }

    [JsonPropertyName("event")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public required ChargeEventEvent Event { get; init; }

    [JsonPropertyName("amount")]
    public required int Amount { get; init; }

    [JsonPropertyName("idempotencyKey")]
    public required string IdempotencyKey { get; init; }

    [JsonPropertyName("success")]
    public required bool Success { get; init; }
}
