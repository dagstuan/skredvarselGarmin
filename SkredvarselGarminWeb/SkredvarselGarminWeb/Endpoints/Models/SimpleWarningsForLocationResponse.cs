namespace SkredvarselGarminWeb.Endpoints.Models;

public class SimpleWarningsForLocationResponse
{
    public required string RegionId { get; set; }
    public required IEnumerable<SimpleAvalancheWarning> Warnings { get; set; }
}
