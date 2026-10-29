namespace SkredvarselGarminWeb.MagicLink;

public class MagicLinkToken
{
    public required string Email { get; init; }
    public required string? UserId { get; init; }
    public required string ReturnUrl { get; init; }
    // Needs a setter so the value from the token is kept when deserializing.
    public DateTime ExpirationTime { get; init; } = DateTime.UtcNow.AddMinutes(10);
}
