using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class DraftAgreementCharge
{
    [JsonPropertyName("amount")]
    public required int Amount { get; init; }

    [JsonPropertyName("description")]
    public required string Description { get; init; }

    [JsonPropertyName("transactionType")]
    public string TransactionType { get; init; } = "RESERVE_CAPTURE";
}
