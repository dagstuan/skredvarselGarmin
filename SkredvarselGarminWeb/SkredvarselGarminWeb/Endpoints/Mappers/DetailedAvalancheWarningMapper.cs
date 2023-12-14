using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints.Mappers;

public static class DetailedAvalancheWarningMapper
{
    public static SimpleAvalancheWarning ToSimpleAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning) => new()
    {
        DangerLevel = int.Parse(varsomWarning.DangerLevel),
        Validity = [
            varsomWarning.ValidFrom,
            varsomWarning.ValidTo,
        ],
        HasEmergency = !string.IsNullOrWhiteSpace(varsomWarning.EmergencyWarning?.ToEmergencyWarning()),
    };

    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning) => new()
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
        EmergencyWarning = varsomWarning.EmergencyWarning?.ToEmergencyWarning()
    };

    private static string? ToEmergencyWarning(this string emergencyWarning) =>
        !string.IsNullOrWhiteSpace(emergencyWarning) &&
        !emergencyWarning.Equals("ikke gitt", StringComparison.CurrentCultureIgnoreCase)
            ? emergencyWarning
            : null;
}
