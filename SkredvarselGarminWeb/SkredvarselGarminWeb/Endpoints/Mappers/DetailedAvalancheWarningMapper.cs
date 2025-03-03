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

    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning, string langKey) => new()
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
        EmergencyWarning = varsomWarning.EmergencyWarning?.ToEmergencyWarning(langKey, varsomWarning.AvalancheProblems)
    };

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
