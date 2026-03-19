using System.Text.Json.Serialization;

using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class DetailedAvalancheWarning
{
    public required DateTime Published { get; init; }
    public required int DangerLevel { get; init; }
    public required DateTime[] Validity { get; init; }
    public required string MainText { get; init; }
    public required IEnumerable<AvalancheProblem>? AvalancheProblems { get; init; }
    public required bool IsTendency { get; init; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public required string? EmergencyWarning { get; init; }
}

public class AvalancheProblem
{
    public required int TypeId { get; init; }
    public required string TypeName { get; init; }

    // Norwegian: [height1, height2, fill] — meter-based elevation
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int[]? ExposedHeights { get; init; }

    // Swedish: [aboveTreeline, atTreeline, belowTreeline] booleans
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public bool[]? ExposedHeightZones { get; init; }

    public required string ValidExpositions { get; init; }
    public required int DangerLevel { get; init; }
    public required DestructiveSizeExt DestructiveSize { get; init; }
    public required AvalTriggerSensitivity TriggerSensitivity { get; init; }
    public required AvalPropagation Propagation { get; init; }
}
