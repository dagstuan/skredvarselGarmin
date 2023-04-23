using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints.Mappers;

public static class DetailedAvalancheWarningMapper
{
    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this VarsomDetailedAvalancheWarning varsomWarning) => new()
    {
        Published = varsomWarning.PublishTime,
        DangerLevel = int.Parse(varsomWarning.DangerLevel),
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
            ValidExpositions = problem.ValidExpositions,
            DangerLevel = problem.DangerLevel,
        })
        .OrderByDescending(x => x.DangerLevel)
        .ToList() ?? new List<AvalancheProblem>()
    };
}
