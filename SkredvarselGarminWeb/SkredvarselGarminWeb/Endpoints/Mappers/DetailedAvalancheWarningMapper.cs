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
        HasEmergency = !string.IsNullOrWhiteSpace(varsomWarning.EmergencyWarning?.ToEmergencyWarning(langKey)),
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
        }).OrderByDescending(x => x.DangerLevel),
        IsTendency = varsomWarning.IsTendency,
        EmergencyWarning = varsomWarning.EmergencyWarning?.ToEmergencyWarning(langKey)
    };

    private static string? ToEmergencyWarning(this string emergencyWarning, string langKey)
    {
        var notGivenText = langKey == "1" ? "ikke gitt" : "not given";

        return !string.IsNullOrWhiteSpace(emergencyWarning) &&
            !emergencyWarning.Equals(notGivenText, StringComparison.CurrentCultureIgnoreCase)
            ? emergencyWarning
            : null;
    }
}
