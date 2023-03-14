using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Agreement
{
    [JsonPropertyName("campaign")]
    public AgreementCampaign? Campaign { get; set; }

    [JsonPropertyName("currency")]
    public string Currency { get; set; } = string.Empty;

    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("interval")]
    public Period Interval { get; set; } = new Period();

    [JsonPropertyName("pricing")]
    public Pricing Pricing { get; set; } = new Pricing();

    [JsonPropertyName("productName")]
    public string ProductName { get; set; } = string.Empty;

    [JsonPropertyName("productDescription")]
    public string ProductDescription { get; set; } = string.Empty;

    [JsonPropertyName("start")]
    public DateTime? Start { get; set; } = DateTime.MinValue;

    [JsonPropertyName("stop")]
    public DateTime? Stop { get; set; } = null;

    [JsonPropertyName("status")]
    public AgreementStatus Status { get; set; }

    [JsonPropertyName("merchantAgreementUrl")]
    public string MerchantAgreementUrl { get; set; } = string.Empty;

    [JsonPropertyName("sub")]
    public string Sub { get; set; } = string.Empty;

    [JsonPropertyName("userinfoUrl")]
    public string UserinfoUrl { get; set; } = string.Empty;
}
