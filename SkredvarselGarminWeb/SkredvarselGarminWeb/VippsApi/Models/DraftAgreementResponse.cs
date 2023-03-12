using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class DraftAgreementResponse
{
    [JsonPropertyName("agreementId")]
    public string AgreementId { get; set; } = string.Empty;

    [JsonPropertyName("vippsConfirmationUrl")]
    public string VippsConfirmationUrl { get; set; } = string.Empty;

    [JsonPropertyName("chargeId")]
    public string ChargeId { get; set; } = string.Empty;
}
