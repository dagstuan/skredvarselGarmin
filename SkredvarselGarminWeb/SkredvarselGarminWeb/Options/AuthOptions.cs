namespace SkredvarselGarminWeb.Options;

public class AuthOptions
{
    public required string AdminEmail { get; init; }
    public required bool UseWatchAuthorization { get; init; }
}
