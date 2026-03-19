using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.LavinprognoserApi.Models;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Endpoints.Mappers;

public static class LavinprognoserWarningMapper
{
    public static SimpleAvalancheWarning ToSimpleAvalancheWarning(this LavinprognoserDetailedWarning warning) => new()
    {
        DangerLevel = warning.DangerLevel,
        Validity = [warning.ValidFrom, warning.ValidTo],
        HasEmergency = false,
    };

    public static DetailedAvalancheWarning ToDetailedAvalancheWarning(this LavinprognoserDetailedWarning warning) => new()
    {
        Published = warning.PublishTime,
        DangerLevel = warning.DangerLevel,
        Validity = [warning.ValidFrom, warning.ValidTo],
        MainText = warning.MainText,
        IsTendency = warning.IsTendency,
        EmergencyWarning = null,
        AvalancheProblems = warning.AvalancheProblems.Select(p => new AvalancheProblem
        {
            TypeId = (int)p.ProblemTypeId,
            TypeName = GetSwedishProblemTypeName(p.ProblemTypeId),
            ExposedHeightZones = [p.AboveTreeline, p.AtTreeline, p.BelowTreeline],
            ValidExpositions = p.ValidExpositions,
            DangerLevel = 0,
            DestructiveSize = p.DestructiveSize,
            TriggerSensitivity = p.TriggerSensitivity,
            Propagation = p.Propagation,
        }),
    };

    // Names match lavinprognoser.se display labels
    private static string GetSwedishProblemTypeName(AvalancheProblemType type) => type switch
    {
        AvalancheProblemType.NewSnowLooseSnowAvalanches => "Nysnölaviner",
        AvalancheProblemType.NewSnowSlabAvalanches => "Nysnöflak",
        AvalancheProblemType.PersistentWeakLayerSlabAvalanches => "Ihållande svagt lager",
        AvalancheProblemType.WindDriftedSnowSlabAvalanches => "Drevsnöflak",
        AvalancheProblemType.WetSnowLooseSnowAvalanches => "Våtsnölaviner",
        AvalancheProblemType.GlidingSnowAvalanches => "Glidlaviner",
        _ => string.Empty,
    };
}
