namespace SkredvarselGarminWeb.Models;

public class DetailedAvalancheWarning
{
    public int DangerLevel { get; init; } = 0;
    public DateTime ValidFrom { get; init; }
    public DateTime ValidTo { get; init; }
    public string MainText { get; init; } = string.Empty;
    public IEnumerable<AvalancheProblem>? AvalancheProblems { get; init; } = new List<AvalancheProblem>();
}

public class AvalancheProblem
{
    public int AvalancheProblemTypeId { get; init; } = 0;
    public string AvalancheProblemTypeName { get; init; } = string.Empty;
    public int ExposedHeight1 { get; init; } = 0;
    public int ExposedHeight2 { get; init; } = 0;
    public int ExposedHeightFill { get; init; } = 0;
    public string ValidExpositions { get; init; } = string.Empty;
}
