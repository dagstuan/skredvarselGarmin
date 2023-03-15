using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class DraftAgreementResponse
{
    [JsonPropertyName("agreementId")]
    public required string AgreementId { get; init; }

    [JsonPropertyName("vippsConfirmationUrl")]
    public required string VippsConfirmationUrl { get; init; }

    [JsonPropertyName("chargeId")]
    public string? ChargeId { get; init; }
}
