namespace SkredvarselGarminWeb.Models;

public class DetailedAvalancheWarning
{
    public int DangerLevel { get; init; } = 0;
    public DateTime[] Validity { get; init; } = Array.Empty<DateTime>();
    public string MainText { get; init; } = string.Empty;
    public IEnumerable<AvalancheProblem>? AvalancheProblems { get; init; } = new List<AvalancheProblem>();
}

public class AvalancheProblem
{
    public string TypeName { get; init; } = string.Empty;
    public int[] ExposedHeights { get; init; } = Array.Empty<int>();
    public string ValidExpositions { get; init; } = string.Empty;
}
