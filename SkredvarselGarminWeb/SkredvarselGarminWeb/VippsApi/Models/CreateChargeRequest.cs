using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class CreateChargeRequest
{
    [JsonPropertyName("transactionType")]
    public string TransactionType { get; } = "RESERVE_CAPTURE";

    [JsonPropertyName("amount")]
    public int Amount { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("due")]
    public DateOnly Due { get; set; }

    [JsonPropertyName("retryDays")]
    public int RetryDays { get; set; }
}
