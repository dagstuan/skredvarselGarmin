namespace SkredvarselGarminWeb.Options;

public class DatabaseOptions
{
    public string Host { get; init; } = string.Empty;
    public int Port { get; init; } = -1;
    public string Username { get; init; } = string.Empty;
    public string Password { get; init; } = string.Empty;
    public string Database { get; init; } = string.Empty;
    public string HangfireDatabase { get; init; } = string.Empty;
}
