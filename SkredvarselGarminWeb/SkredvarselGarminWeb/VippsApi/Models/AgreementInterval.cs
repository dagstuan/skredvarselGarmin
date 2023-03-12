using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class AgreementInterval
{
    [JsonPropertyName("unit")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public PeriodUnit Unit { get; set; } = PeriodUnit.Month;

    [JsonPropertyName("count")]
    public int Count { get; set; } = 0;

    [JsonPropertyName("text")]
    public string Text { get; set; } = string.Empty;
}
