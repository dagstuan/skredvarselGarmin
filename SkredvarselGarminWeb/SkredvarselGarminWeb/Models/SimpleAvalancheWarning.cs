namespace SkredvarselGarminWeb.Models;

public class SimpleAvalancheWarning
{
    public int DangerLevel { get; init; } = 0;
    public DateTime ValidFrom { get; init; }
    public DateTime ValidTo { get; init; }
}
