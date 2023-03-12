using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Period
{
    [JsonPropertyName("unit")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public PeriodUnit Unit { get; set; } = PeriodUnit.Month;

    [JsonPropertyName("count")]
    public int Count { get; set; } = 0;
}
