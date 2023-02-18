namespace SkredvarselGarminWeb.VarsomApi.Models;

public class VarsomDetailedAvalancheWarning
{
    public DateTime ValidFrom { get; init; }
    public DateTime ValidTo { get; init; }
    public int DangerLevel { get; init; } = 0;
    public string MainText { get; init; } = string.Empty;
    public IEnumerable<VarsomAvalancheProblem> AvalancheProblems { get; init; } = new List<VarsomAvalancheProblem>();
}

public class VarsomAvalancheProblem
{
    public string AvalancheProblemTypeName { get; init; } = string.Empty;
    public int AvalancheProblemTypeId { get; init; } = 0;
    public int ExposedHeight1 { get; init; } = 0;
    public int ExposedHeight2 { get; init; } = 0;
    public int ExposedHeightFill { get; init; } = 0;
    public string ValidExpositions { get; init; } = string.Empty;
}
