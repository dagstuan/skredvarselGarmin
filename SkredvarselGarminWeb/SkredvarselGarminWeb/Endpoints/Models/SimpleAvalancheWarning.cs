namespace SkredvarselGarminWeb.Endpoints.Models;

public class SimpleAvalancheWarning
{
    public required int DangerLevel { get; init; }
    public required DateTime[] Validity { get; init; }
    public required bool HasEmergency { get; init; }
}
