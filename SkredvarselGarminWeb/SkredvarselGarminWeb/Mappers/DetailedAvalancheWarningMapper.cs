using SkredvarselGarminWeb.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Mappers;

public static class DetailedAvalancheWarningMapper
{
    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning) => new()
    {
        DangerLevel = varsomWarning.DangerLevel,
        ValidFrom = varsomWarning.ValidFrom,
        ValidTo = varsomWarning.ValidTo,
        MainText = varsomWarning.MainText,
        AvalancheProblems = varsomWarning.AvalancheProblems?.Select(problem => new AvalancheProblem()
        {
            AvalancheProblemTypeId = problem.AvalancheProblemTypeId,
            AvalancheProblemTypeName = problem.AvalancheProblemTypeName,
            ExposedHeight1 = problem.ExposedHeight1,
            ExposedHeight2 = problem.ExposedHeight2,
            ExposedHeightFill = problem.ExposedHeightFill,
            ValidExpositions = problem.ValidExpositions
        })
    };
}
