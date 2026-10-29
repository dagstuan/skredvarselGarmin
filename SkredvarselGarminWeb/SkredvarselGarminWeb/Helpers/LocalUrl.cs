namespace SkredvarselGarminWeb.Helpers;

public static class LocalUrl
{
    // True for paths on this site, like "/en/account?watchKey=x". Rejects absolute and
    // protocol-relative urls ("//evil.example", "/\evil.example") to prevent open redirects.
    public static bool IsLocal(string? url) =>
        !string.IsNullOrEmpty(url)
        && url[0] == '/'
        && (url.Length == 1 || (url[1] != '/' && url[1] != '\\'));
}
