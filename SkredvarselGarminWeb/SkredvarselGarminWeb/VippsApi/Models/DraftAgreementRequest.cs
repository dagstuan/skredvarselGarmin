using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class DraftAgreementRequest
{
    [JsonPropertyName("pricing")]
    public required Pricing Pricing { get; init; }

    [JsonPropertyName("interval")]
    public required Period Interval { get; init; }

    [JsonPropertyName("merchantRedirectUrl")]
    public required string MerchantRedirectUrl { get; init; }

    [JsonPropertyName("merchantAgreementUrl")]
    public required string MerchantAgreementUrl { get; init; }

    [JsonPropertyName("customerPhoneNumber")]
    public string? CustomerPhoneNumber { get; init; }

    [JsonPropertyName("productName")]
    public required string ProductName { get; init; }

    [JsonPropertyName("campaign")]
    public AgreementCampaign? Campaign { get; init; }

    [JsonPropertyName("initialCharge")]
    public DraftAgreementCharge? InitialCharge { get; init; }

    [JsonPropertyName("scope")]
    public string? Scope { get; init; }
}
