namespace SkredvarselGarminWeb.Endpoints.Models;

public class FormerSubscriberAdminUser
{
    public required string Id { get; set; }
    public required string? Name { get; set; }
    public required string Email { get; set; }
    public required DateOnly LastLoggedIn { get; set; }
}
