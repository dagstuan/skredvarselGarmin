namespace SkredvarselGarminWeb.Models;

public class SimpleAvalancheWarning
{
    public string DangerLevel { get; init; } = "unknown";
    public DateTime ValidFrom { get; init; }
    public DateTime ValidTo { get; init; }
}
