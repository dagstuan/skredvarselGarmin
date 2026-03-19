using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.LavinprognoserApi.Models;

public class LavinprognoserLocation
{
    [JsonPropertyName("id")]
    public required int Id { get; init; }
}
