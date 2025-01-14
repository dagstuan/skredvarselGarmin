namespace SkredvarselGarminWeb.Endpoints.Models;

public class SimpleWarningsForLocationResponse
{
    public required int LocationId { get; set; }
    public required IEnumerable<SimpleAvalancheWarning> Warnings { get; set; }
}
