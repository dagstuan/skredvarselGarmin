namespace SkredvarselGarminWeb.Models;

public class SimpleAvalancheWarning
{
    public int DangerLevel { get; init; } = 0;
    public DateTime[] Validity { get; init; } = Array.Empty<DateTime>();
}
