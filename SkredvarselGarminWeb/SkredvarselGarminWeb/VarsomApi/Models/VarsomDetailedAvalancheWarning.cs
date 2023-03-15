namespace SkredvarselGarminWeb.VarsomApi.Models;

public class VarsomDetailedAvalancheWarning
{
    public required DateTime ValidFrom { get; init; }
    public required DateTime ValidTo { get; init; }
    public required string DangerLevel { get; init; }
    public required string MainText { get; init; }
    public required IEnumerable<VarsomAvalancheProblem> AvalancheProblems { get; init; }
}

public class VarsomAvalancheProblem
{
    public required string AvalancheProblemTypeName { get; init; }
    public required int AvalancheProblemTypeId { get; init; }
    public required int ExposedHeight1 { get; init; }
    public required int ExposedHeight2 { get; init; }
    public required int ExposedHeightFill { get; init; }
    public required string ValidExpositions { get; init; }
}
