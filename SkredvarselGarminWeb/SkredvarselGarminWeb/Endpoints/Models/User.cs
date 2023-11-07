namespace SkredvarselGarminWeb.Endpoints.Models;

public class User
{
    public required string Name { get; init; }
    public required string Email { get; init; }
    public required string PhoneNumber { get; init; }
    public required bool IsAdmin { get; init; }
}
