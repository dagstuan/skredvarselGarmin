using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints.Mappers;

public static class DetailedAvalancheWarningMapper
{
    public static SimpleAvalancheWarning ToSimpleAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning, string langKey) => new()
    {
        DangerLevel = int.Parse(varsomWarning.DangerLevel),
        Validity = [
            varsomWarning.ValidFrom,
            varsomWarning.ValidTo,
        ],
        HasEmergency = !string.IsNullOrWhiteSpace(varsomWarning.EmergencyWarning?.ToEmergencyWarning(langKey, varsomWarning.AvalancheProblems)),
    };

    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning, string langKey, bool includeSnowpackAndWeather = false) => new()
    {
        Published = varsomWarning.PublishTime,
        DangerLevel = int.Parse(varsomWarning.DangerLevel),
        Validity = [
            varsomWarning.ValidFrom,
            varsomWarning.ValidTo,
        ],
        MainText = varsomWarning.MainText,
        AvalancheProblems = (varsomWarning.AvalancheProblems ?? [])?.Select(problem => new AvalancheProblem()
        {
            TypeId = (int)problem.AvalancheProblemTypeId,
            TypeName = problem.AvalancheProblemTypeName,
            ExposedHeights = [
                problem.ExposedHeight1,
                problem.ExposedHeight2,
                problem.ExposedHeightFill,
            ],
            ValidExpositions = problem.ValidExpositions,
            DangerLevel = problem.DangerLevel,
            DestructiveSize = problem.DestructiveSizeExtId,
            TriggerSensitivity = problem.AvalTriggerSensitivityId,
            Propagation = problem.AvalPropagationId,
        }).OrderByDescending(x => x.DangerLevel),
        IsTendency = varsomWarning.IsTendency,
        EmergencyWarning = varsomWarning.EmergencyWarning?.ToEmergencyWarning(langKey, varsomWarning.AvalancheProblems),
        SnowpackHistory = includeSnowpackAndWeather ? varsomWarning.ToSnowpackHistory() : null,
        MountainWeather = includeSnowpackAndWeather ? varsomWarning.MountainWeather.ToMountainWeather() : null,
    };

    // Matches the "Snødekkehistorikk" section on varsom.no, one paragraph per line.
    private static string ToSnowpackHistory(this VarsomDetailedAvalancheWarning varsomWarning) =>
        JoinSentences("\n", [
            varsomWarning.SnowSurface,
            varsomWarning.CurrentWeaklayers,
            varsomWarning.LatestAvalancheActivity,
            varsomWarning.LatestObservations,
        ]);

    // Matches the "Fjellvær" section on varsom.no.
    private static string ToMountainWeather(this VarsomMountainWeather? mountainWeather) =>
        mountainWeather == null ? string.Empty : JoinSentences(" ", [
            .. (mountainWeather.MeasurementTexts ?? [])
                .OrderBy(measurementText => measurementText.SortOrder)
                .Select(measurementText => measurementText.Text),
            mountainWeather.CloudCoverName,
            mountainWeather.Comment,
        ]);

    private static string JoinSentences(string separator, IEnumerable<string?> sentences) =>
        string.Join(separator, sentences
            .Where(sentence => !string.IsNullOrWhiteSpace(sentence))
            .Select(sentence => sentence!.Trim())
            .Select(sentence => char.IsLetterOrDigit(sentence[^1]) ? $"{sentence}." : sentence));

    private static string? ToEmergencyWarning(this string emergencyWarning, string langKey, IEnumerable<VarsomAvalancheProblem>? avalancheProblems)
    {
        const string langKeyNorwegian = "1";
        const string langKeyEnglish = "2";
        const string notGivenNorwegian = "ikke gitt";
        const string notGivenEnglish = "not given";

        var hasPersistentWeakLayer = avalancheProblems?.Any(problem => problem.AvalancheProblemTypeId == AvalancheProblemType.PersistentWeakLayerSlabAvalanches) ?? false;

        var persistentWeakLayerWarning = hasPersistentWeakLayer ? langKey == langKeyNorwegian ? "Vedvarende svakt lag" : "Persistent weak layer" : null;

        return (langKey, emergencyWarning.ToLower(), persistentWeakLayerWarning) switch
        {
            (langKeyNorwegian, notGivenNorwegian, null) => null,
            (langKeyEnglish, notGivenEnglish, null) => null,
            (langKeyNorwegian, _, null) => emergencyWarning,
            (langKeyEnglish, _, null) => emergencyWarning,
            (langKeyNorwegian, notGivenNorwegian, _) => $"{persistentWeakLayerWarning}.",
            (langKeyEnglish, notGivenEnglish, _) => $"{persistentWeakLayerWarning}.",
            (_, _, _) => $"{persistentWeakLayerWarning}. {emergencyWarning}.",
        };
    }
}
