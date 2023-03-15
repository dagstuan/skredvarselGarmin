using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Charge
{
    [JsonPropertyName("currency")]
    public string Currency { get; init; } = "NOK";

    [JsonPropertyName("status")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public required ChargeStatus Status { get; init; }

    [JsonPropertyName("type")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public required ChargeType Type { get; init; }

    [JsonPropertyName("transactionType")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public required TransactionType TransactionType { get; init; }

    [JsonPropertyName("failureReason")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public FailureReasonEnum? FailureReason { get; init; }

    [JsonPropertyName("amount")]
    public required int Amount { get; init; }

    [JsonPropertyName("description")]
    public required string Description { get; init; }

    [JsonPropertyName("due")]
    public DateTime Due { get; init; }

    [JsonPropertyName("id")]
    public required string Id { get; init; }

    [JsonPropertyName("transactionId")]
    public required string TransactionId { get; init; }

    [JsonPropertyName("failureDescription")]
    public string? FailureDescription { get; init; }

    [JsonPropertyName("summary")]
    public required ChargeSummary Summary { get; init; }

    [JsonPropertyName("history")]
    public required List<ChargeEvent> History { get; init; }
}
