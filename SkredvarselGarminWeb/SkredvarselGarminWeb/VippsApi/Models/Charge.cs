using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Charge
{
    [JsonPropertyName("currency")]
    public string Currency { get; set; } = "NOK";

    [JsonPropertyName("status")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public ChargeStatus Status { get; set; }

    [JsonPropertyName("type")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public ChargeType Type { get; set; }

    [JsonPropertyName("transactionType")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public TransactionType TransactionType { get; set; }

    [JsonPropertyName("failureReason")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public FailureReasonEnum? FailureReason { get; set; }

    [JsonPropertyName("amount")]
    public int Amount { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("due")]
    public DateTime Due { get; set; }

    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("transactionId")]
    public string TransactionId { get; set; } = string.Empty;

    [JsonPropertyName("failureDescription")]
    public string FailureDescription { get; set; } = string.Empty;

    [JsonPropertyName("summary")]
    public ChargeSummary Summary { get; set; } = new ChargeSummary();

    [JsonPropertyName("history")]
    public List<ChargeEvent> History { get; set; } = new List<ChargeEvent>();
}
