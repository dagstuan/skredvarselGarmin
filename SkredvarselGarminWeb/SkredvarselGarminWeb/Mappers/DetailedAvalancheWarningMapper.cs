using SkredvarselGarminWeb.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Mappers;

public static class DetailedAvalancheWarningMapper
{
    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning) => new()
    {
        DangerLevel = varsomWarning.DangerLevel,
        Validity = new DateTime[] {
            varsomWarning.ValidFrom,
            varsomWarning.ValidTo,
        },
        MainText = varsomWarning.MainText,
        AvalancheProblems = varsomWarning.AvalancheProblems?.Select(problem => new AvalancheProblem()
        {
            TypeName = problem.AvalancheProblemTypeName,
            ExposedHeights = new int[] {
                problem.ExposedHeight1,
                problem.ExposedHeight2,
                problem.ExposedHeightFill,
            },
            ValidExpositions = problem.ValidExpositions
        }) ?? new List<AvalancheProblem>()
    };
}
