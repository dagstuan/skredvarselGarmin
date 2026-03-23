using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.LavinprognoserApi.Models;

public class WfsFeatureCollection<TProperties>
{
    [JsonPropertyName("features")]
    public required IEnumerable<WfsFeature<TProperties>> Features { get; init; }
}

public class WfsFeature<TProperties>
{
    [JsonPropertyName("properties")]
    public required TProperties Properties { get; init; }

    [JsonPropertyName("geometry")]
    public WfsGeometry? Geometry { get; init; }
}

public class WfsGeometry
{
    [JsonPropertyName("type")]
    public required string Type { get; init; }

    // Polygon: array of rings, each ring is array of [x, y] pairs
    [JsonPropertyName("coordinates")]
    public required double[][][] Coordinates { get; init; }
}
