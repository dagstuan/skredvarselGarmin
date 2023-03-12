using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class DraftAgreementRequest
{
    [JsonPropertyName("pricing")]
    public Pricing Pricing { get; set; } = new Pricing();

    [JsonPropertyName("interval")]
    public Period Interval { get; set; } = new Period();

    [JsonPropertyName("merchantRedirectUrl")]
    public string MerchantRedirectUrl { get; set; } = string.Empty;

    [JsonPropertyName("merchantAgreementUrl")]
    public string MerchantAgreementUrl { get; set; } = string.Empty;

    [JsonPropertyName("customerPhoneNumber")]
    public string CustomerPhoneNumber { get; set; } = string.Empty;

    [JsonPropertyName("productName")]
    public string ProductName { get; set; } = string.Empty;

    [JsonPropertyName("campaign")]
    public AgreementCampaign Campaign { get; set; } = new AgreementCampaign();

    [JsonPropertyName("initialCharge")]
    public DraftAgreementCharge InitialCharge { get; set; } = new DraftAgreementCharge();
}
