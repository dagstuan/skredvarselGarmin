using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class CreateChargeResponse
{
    [JsonPropertyName("chargeId")]
    public string ChargeId { get; set; } = string.Empty;
}
