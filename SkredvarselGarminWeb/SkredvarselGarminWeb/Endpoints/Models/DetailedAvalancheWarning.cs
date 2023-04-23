namespace SkredvarselGarminWeb.Endpoints.Models;

public class DetailedAvalancheWarning
{
    public required DateTime Published { get; init; }
    public required int DangerLevel { get; init; }
    public required DateTime[] Validity { get; init; }
    public required string MainText { get; init; }
    public required IEnumerable<AvalancheProblem>? AvalancheProblems { get; init; }
}

public class AvalancheProblem
{
    public required string TypeName { get; init; }
    public required int[] ExposedHeights { get; init; }
    public required string ValidExpositions { get; init; }
    public required int DangerLevel { get; init; }
}
