namespace SkredvarselGarminWeb.VarsomApi.Models;

public class VarsomSimpleAvalancheWarning
{
    public required int RegId { get; init; }
    public required int RegionId { get; init; }
    public required string RegionName { get; init; }
    public required int RegionTypeId { get; init; }
    public required string RegionTypeName { get; init; }
    public required string DangerLevel { get; init; }
    public required DateTime ValidFrom { get; init; }
    public required DateTime ValidTo { get; init; }
    public required DateTime NextWarningTime { get; init; }
    public required DateTime PublishTime { get; init; }
    public required DateTime? DangerIncreaseTime { get; init; }
    public required DateTime? DangerDecreaseTime { get; init; }
    public required string MainText { get; init; }
    public required int LangKey { get; init; }
}
