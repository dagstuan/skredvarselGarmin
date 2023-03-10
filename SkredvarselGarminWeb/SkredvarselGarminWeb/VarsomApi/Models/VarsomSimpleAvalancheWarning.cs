namespace SkredvarselGarminWeb.VarsomApi.Models;

public class VarsomSimpleAvalancheWarning
{
    public int RegId { get; init; }
    public int RegionId { get; init; }
    public string RegionName { get; init; } = "Unknown";
    public int RegionTypeId { get; init; }
    public string RegionTypeName { get; init; } = "Unknown";
    public int DangerLevel { get; init; } = 0;
    public DateTime ValidFrom { get; init; }
    public DateTime ValidTo { get; init; }
    public DateTime NextWarningTime { get; init; }
    public DateTime PublishTime { get; init; }
    public DateTime? DangerIncreaseTime { get; init; }
    public DateTime? DangerDecreaseTime { get; init; }
    public string MainText { get; init; } = string.Empty;
    public int LangKey { get; init; }
}
