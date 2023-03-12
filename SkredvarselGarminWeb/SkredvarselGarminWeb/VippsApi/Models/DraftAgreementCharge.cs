using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class DraftAgreementCharge
{
    [JsonPropertyName("amount")]
    public int Amount { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("transactionType")]
    public string TransactionType { get; init; } = "RESERVE_CAPTURE";
}
