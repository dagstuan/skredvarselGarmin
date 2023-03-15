using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class CreateChargeRequest
{
    [JsonPropertyName("transactionType")]
    public string TransactionType { get; init; } = "RESERVE_CAPTURE";

    [JsonPropertyName("amount")]
    public required int Amount { get; init; }

    [JsonPropertyName("description")]
    public required string Description { get; init; }

    [JsonPropertyName("due")]
    public required DateOnly Due { get; init; }

    [JsonPropertyName("retryDays")]
    public required int RetryDays { get; init; }
}
