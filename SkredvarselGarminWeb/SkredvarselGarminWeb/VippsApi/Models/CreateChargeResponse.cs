using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class CreateChargeResponse
{
    [JsonPropertyName("chargeId")]
    public required string ChargeId { get; init; }
}
