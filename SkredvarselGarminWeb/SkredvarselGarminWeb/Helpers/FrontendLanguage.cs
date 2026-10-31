namespace SkredvarselGarminWeb.Helpers;

public static class FrontendLanguage
{
    // Path prefix for the frontend's localized routes. Norwegian is the default and has no prefix.
    public static string GetPathPrefix(string? lang) => lang switch
    {
        "en" => "/en",
        "sv" => "/sv",
        _ => "",
    };

    // Reads the language from a frontend path, e.g. "/en/account?watchKey=x" gives "en".
    // Returns null for Norwegian paths, which have no prefix.
    public static string? GetLanguageFromPath(string path)
    {
        foreach (var lang in new[] { "en", "sv" })
        {
            if (path == $"/{lang}" || path.StartsWith($"/{lang}/") || path.StartsWith($"/{lang}?"))
            {
                return lang;
            }
        }

        return null;
    }

    public static string GetPathPrefixFromPath(string path) => GetPathPrefix(GetLanguageFromPath(path));

    public static string GetStripeLocale(string? lang) => lang switch
    {
        "en" => "en",
        "sv" => "sv",
        _ => "nb",
    };
}
