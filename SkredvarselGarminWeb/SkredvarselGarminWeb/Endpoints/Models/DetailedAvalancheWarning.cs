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
    public required string TypeName { get; init; }
    public required int[] ExposedHeights { get; init; }
    public required string ValidExpositions { get; init; }
    public required int DangerLevel { get; init; }
    public required DestructiveSizeExt DestructiveSize { get; init; }
    public required AvalTriggerSensitivity TriggerSensitivity { get; init; }
    public required AvalPropagation Propagation { get; init; }
}
