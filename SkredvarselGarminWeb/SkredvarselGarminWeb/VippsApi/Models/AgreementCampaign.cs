using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class AgreementCampaign
{
    [JsonPropertyName("type")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public required CampaignType Type { get; init; }

    [JsonPropertyName("price")]
    public required int Price { get; init; }

    [JsonPropertyName("end")]
    public DateTime? End { get; init; }

    [JsonPropertyName("period")]
    public Period? Period { get; init; }
}
