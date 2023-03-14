using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class AgreementCampaign
{
    [JsonPropertyName("type")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public CampaignType Type { get; set; } = CampaignType.PeriodCampaign;

    [JsonPropertyName("price")]
    public int Price { get; set; } = 0;

    [JsonPropertyName("end")]
    public DateTime? End { get; set; }

    [JsonPropertyName("period")]
    public Period? Period { get; set; }
}
