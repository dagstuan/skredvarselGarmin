namespace SkredvarselGarminWeb.Endpoints.Models;

public class SwedishAreaSummary
{
    public required int Id { get; init; }
    public required string Name { get; init; }
    public int? ParentId { get; init; }
}
