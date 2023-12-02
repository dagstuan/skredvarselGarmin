namespace SkredvarselGarminWeb.ServiceModels;

public class UserLogin
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    public required string Email { get; init; }
    public required string PhoneNumber { get; init; }
}
