using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class Period
{
    [JsonPropertyName("unit")]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public required PeriodUnit Unit { get; init; }

    [JsonPropertyName("count")]
    public required int Count { get; init; }
}
