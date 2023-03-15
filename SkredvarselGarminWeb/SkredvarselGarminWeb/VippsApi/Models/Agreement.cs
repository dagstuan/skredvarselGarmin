using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Agreement
{
    [JsonPropertyName("campaign")]
    public AgreementCampaign? Campaign { get; init; }

    [JsonPropertyName("currency")]
    public string Currency { get; init; } = "NOK";

    [JsonPropertyName("id")]
    public required string Id { get; init; }

    [JsonPropertyName("interval")]
    public required Period Interval { get; init; }

    [JsonPropertyName("pricing")]
    public required Pricing Pricing { get; init; }

    [JsonPropertyName("productName")]
    public required string ProductName { get; init; }

    [JsonPropertyName("productDescription")]
    public required string ProductDescription { get; init; }

    [JsonPropertyName("start")]
    public DateTime? Start { get; init; }

    [JsonPropertyName("stop")]
    public DateTime? Stop { get; init; }

    [JsonPropertyName("status")]
    public required AgreementStatus Status { get; init; }

    [JsonPropertyName("merchantAgreementUrl")]
    public required string MerchantAgreementUrl { get; init; }

    [JsonPropertyName("sub")]
    public string? Sub { get; init; }

    [JsonPropertyName("userinfoUrl")]
    public string? UserinfoUrl { get; init; }
}
