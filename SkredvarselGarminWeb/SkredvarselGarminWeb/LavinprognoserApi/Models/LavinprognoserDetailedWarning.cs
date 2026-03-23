using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi.Models;

public class LavinprognoserDetailedWarning
{
    public required DateTime PublishTime { get; init; }
    public required DateTime ValidFrom { get; init; }
    public required DateTime ValidTo { get; init; }
    public required int DangerLevel { get; init; }
    public required string MainText { get; init; }
    public required bool IsTendency { get; init; }
    public required IEnumerable<LavinprognoserAvalancheProblem> AvalancheProblems { get; init; }
}

public class LavinprognoserAvalancheProblem
{
    public required AvalancheProblemType ProblemTypeId { get; init; }
    public required bool AboveTreeline { get; init; }
    public required bool AtTreeline { get; init; }
    public required bool BelowTreeline { get; init; }
    public required string ValidExpositions { get; init; }
    public required DestructiveSizeExt DestructiveSize { get; init; }
    public required AvalTriggerSensitivity TriggerSensitivity { get; init; }
    public required AvalPropagation Propagation { get; init; }
}
