namespace SkredvarselGarminWeb.Endpoints.Models;

public class DetailedWarningsForLocationResponse
{
    public required string RegionId { get; set; }
    public required IEnumerable<DetailedAvalancheWarning> Warnings { get; set; }
}
