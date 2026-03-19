using SkredvarselGarminWeb.LavinprognoserApi.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public static partial class LavinprognoserWarningMapper
{
    public static LavinprognoserDetailedWarning ToMissingWarning(this DateOnly day)
    {
        var dayStart = day.ToDateTime(TimeOnly.MinValue);
        var validFrom = dayStart.AddDays(-1).AddHours(18);
        var validTo = dayStart.AddHours(18);

        return new LavinprognoserDetailedWarning
        {
            PublishTime = validFrom,
            ValidFrom = validFrom,
            ValidTo = validTo,
            DangerLevel = 0,
            MainText = string.Empty,
            IsTendency = false,
            AvalancheProblems = [],
        };
    }

    // Swedish date format: "onsdag 04-03-2026 18:00"
    private static readonly string[] SwedishDateFormats = ["dddd dd-MM-yyyy HH:mm", "dddd d-MM-yyyy HH:mm"];
    private static readonly System.Globalization.CultureInfo SwedishCulture =
        System.Globalization.CultureInfo.GetCultureInfo("sv-SE");

    public static LavinprognoserDetailedWarning ToDetailedWarning(this LavinprognoserWebForecast forecast)
    {
        var publishedDate = DateTime.Parse(forecast.PublishedDate);
        var validFrom = ParseSwedishDate(forecast.ValidFrom);
        var validTo = ParseSwedishDate(forecast.ValidTo);
        var isTendency = forecast.Trend != null && DateTime.Parse(forecast.Trend.Date).Date > validFrom.Date;

        return new LavinprognoserDetailedWarning
        {
            PublishTime = publishedDate,
            ValidFrom = validFrom,
            ValidTo = validTo,
            DangerLevel = forecast.Risk,
            MainText = StripHtml(forecast.AssessmentContent),
            IsTendency = isTendency,
            AvalancheProblems = [.. (forecast.AvalancheProblemContainer?.Problems ?? []).Select(problem => problem.ToAvalancheProblem())],
        };
    }

    public static LavinprognoserAvalancheProblem ToAvalancheProblem(this LavinprognoserWebProblem problem) =>
        new()
        {
            ProblemTypeId = MapProblemTypeId(problem.ProblemId),
            AboveTreeline = problem.Altitude?.AboveTreeline?.State ?? false,
            AtTreeline = problem.Altitude?.Treeline?.State ?? false,
            BelowTreeline = problem.Altitude?.BelowTreeline?.State ?? false,
            ValidExpositions = problem.Direction.ToValidExpositions(),
            DestructiveSize = MapSizeMeterValue(problem.Spread?.SizeMeterValue),
            TriggerSensitivity = MapSensitivityId(problem.Spread?.SensitivityId ?? 0),
            Propagation = MapSpreadId(problem.Spread?.SpreadId ?? 0),
        };

    private static string ToValidExpositions(this LavinprognoserWebDirection? direction)
    {
        if (direction == null) return "00000000";
        static char B(LavinprognoserWebPanel? panel) => panel?.State == true ? '1' : '0';
        return new string([
            B(direction.North),
            B(direction.NorthEast),
            B(direction.East),
            B(direction.SouthEast),
            B(direction.South),
            B(direction.SouthWest),
            B(direction.West),
            B(direction.NorthWest),
        ]);
    }

    private static DateTime ParseSwedishDate(string value) =>
        DateTime.ParseExact(value, SwedishDateFormats, SwedishCulture,
            System.Globalization.DateTimeStyles.None);

    private static string StripHtml(string? html)
    {
        if (string.IsNullOrWhiteSpace(html)) return string.Empty;
        var stripped = StyleBlockRegex().Replace(html, " ");
        stripped = HtmlCommentRegex().Replace(stripped, " ");
        stripped = HtmlTagRegex().Replace(stripped, " ");
        stripped = System.Net.WebUtility.HtmlDecode(stripped);
        return WhitespaceRegex().Replace(stripped, " ").Trim();
    }

    // Swedish problem type ID → Varsom/EAWS AvalancheProblemType
    private static AvalancheProblemType MapProblemTypeId(int id) => id switch
    {
        1 => AvalancheProblemType.NewSnowLooseSnowAvalanches,
        2 => AvalancheProblemType.WindDriftedSnowSlabAvalanches,
        3 => AvalancheProblemType.PersistentWeakLayerSlabAvalanches,
        4 => AvalancheProblemType.WetSnowLooseSnowAvalanches,
        5 => AvalancheProblemType.GlidingSnowAvalanches,
        6 => AvalancheProblemType.WindDriftedSnowSlabAvalanches,
        7 => AvalancheProblemType.NewSnowSlabAvalanches,
        _ => AvalancheProblemType.NotGiven,
    };

    // Swedish sensitivity_id: 1=Low, 2=Moderate, 3=Considerable, 4=Touchy, 5=Very Touchy
    private static AvalTriggerSensitivity MapSensitivityId(int id) => id switch
    {
        1 => AvalTriggerSensitivity.VeryHardToTrigger,
        2 => AvalTriggerSensitivity.HardToTrigger,
        3 => AvalTriggerSensitivity.EasyToTrigger,
        4 => AvalTriggerSensitivity.VeryEasyToTrigger,
        5 => AvalTriggerSensitivity.NaturallyTriggered,
        _ => AvalTriggerSensitivity.NotGiven,
    };

    // Swedish spread_id: 1=Isolated, 2=Few, 3=Some, 4=Many, 5=Most, 6=Specific
    private static AvalPropagation MapSpreadId(int id) => id switch
    {
        1 or 6 => AvalPropagation.FewSteepSlopes,
        2 or 3 => AvalPropagation.SomeSteepSlopes,
        4 or 5 => AvalPropagation.ManySteepSlopes,
        _ => AvalPropagation.NotGiven,
    };

    // size_meter_value is a UI slider value cross-referenced against problems_by_interval_new:
    // observed values: ~5→1, ~40→2, ~85→3, ~130→4, ~165→5
    private static DestructiveSizeExt MapSizeMeterValue(int? value) => value switch
    {
        <= 20 => DestructiveSizeExt.Small,
        <= 60 => DestructiveSizeExt.Medium,
        <= 110 => DestructiveSizeExt.Large,
        <= 150 => DestructiveSizeExt.VeryLarge,
        _ when value != null => DestructiveSizeExt.Extreme,
        _ => DestructiveSizeExt.NotGiven,
    };

    // Matches <style>...</style> blocks (including contents)
    [System.Text.RegularExpressions.GeneratedRegex(@"<style[^>]*>[\s\S]*?</style>", System.Text.RegularExpressions.RegexOptions.IgnoreCase)]
    private static partial System.Text.RegularExpressions.Regex StyleBlockRegex();

    // Matches HTML comments including conditional comments <!--...-->
    [System.Text.RegularExpressions.GeneratedRegex(@"<!--[\s\S]*?-->")]
    private static partial System.Text.RegularExpressions.Regex HtmlCommentRegex();

    // Matches any remaining HTML tag
    [System.Text.RegularExpressions.GeneratedRegex(@"<[^>]+>")]
    private static partial System.Text.RegularExpressions.Regex HtmlTagRegex();

    [System.Text.RegularExpressions.GeneratedRegex(@"\s+")]
    private static partial System.Text.RegularExpressions.Regex WhitespaceRegex();
}
