namespace SkredvarselGarminWeb.MagicLink;

public class MagicLinkToken
{
    public required string Email { get; init; }
    public required string? UserId { get; init; }
    public required string ReturnUrl { get; init; }
    public DateTime ExpirationTime { get; } = DateTime.Now.AddMinutes(10);
}
