namespace SkredvarselGarminWeb.LavinprognoserApi;

public static class SwedishForecastAreaRegistry
{
    private const string ForecastAreaPathPrefix = "/oversikt-alla-omraden/";
    private const string JsonPathSuffix = "/index.json";

    public static IReadOnlyDictionary<int, SwedishForecastArea> AreasById { get; } = new Dictionary<int, SwedishForecastArea>
    {
        [2] = new SwedishForecastArea("Abisko/Riksgränsfjällen", "abisko_riksgransfjallen"),
        [7] = new SwedishForecastArea("Vastra Harjedalen", "vastra_harjedalsfjallen"),
        [11] = new SwedishForecastArea("Kebnekaise Ost", "kebnekaisefjallen/kebnekaisefjallen-ost"),
        [12] = new SwedishForecastArea("Sodra Jamtland Vast", "sodra_jamtlandsfjallen/sodra-jamtlandsfjallen-vast"),
        [14] = new SwedishForecastArea("Sodra Jamtland Ost", "sodra_jamtlandsfjallen/sodra-jamtlandsfjallen-ost"),
        [17] = new SwedishForecastArea("Kebnekaise Vast", "kebnekaisefjallen/kebnekaisefjallen-vast"),
        [18] = new SwedishForecastArea("Vastra Vindelfjallen Vast", "vastra_vindelfjallen/vastra-vindelfjallen-vast"),
        [19] = new SwedishForecastArea("Vastra Vindelfjallen Ost", "vastra_vindelfjallen/vastra-vindelfjallen-ost"),
        [20] = new SwedishForecastArea("Sodra Lappland Nord", "sodra_lapplandsfjallen/sodra-lapplandsfjallen-nord"),
        [21] = new SwedishForecastArea("Sodra Lappland Syd", "sodra_lapplandsfjallen/sodra-lapplandsfjallen-syd"),
    };

    public static string? GetSlug(int areaId) =>
        AreasById.TryGetValue(areaId, out var area) ? area.Slug : null;

    public static string? GetName(int areaId) =>
        AreasById.TryGetValue(areaId, out var area) ? area.Name : null;

    public static bool ContainsAreaId(int areaId) => AreasById.ContainsKey(areaId);

    public static string? TryGetSlugFromRequestUri(Uri? uri)
    {
        if (uri == null)
        {
            return null;
        }

        var path = uri.AbsolutePath;
        if (!path.StartsWith(ForecastAreaPathPrefix, StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        var relativePath = path[ForecastAreaPathPrefix.Length..].TrimEnd('/');
        if (relativePath.EndsWith(JsonPathSuffix, StringComparison.OrdinalIgnoreCase))
        {
            relativePath = relativePath[..^JsonPathSuffix.Length];
        }

        return string.IsNullOrWhiteSpace(relativePath) ? null : relativePath.Trim('/');
    }
}

public sealed record SwedishForecastArea(string Name, string Slug);
