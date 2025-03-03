namespace SkredvarselGarminWeb.VarsomApi.Models;

public enum AvalancheProblemType
{
    NotGiven = 0,
    NewSnowLooseSnowAvalanches = 3,
    WetSnowLooseSnowAvalanches = 5,
    NewSnowSlabAvalanches = 7,
    WindDriftedSnowSlabAvalanches = 10,
    PersistentWeakLayerSlabAvalanches = 30,
    WetSnowSlabAvalanches = 45,
    GlidingSnowAvalanches = 50,
}

public enum DestructiveSizeExt
{
    NotGiven = 0,
    Small = 1,
    Medium = 2,
    Large = 3,
    VeryLarge = 4,
    Extreme = 5,
}

public enum AvalTriggerSensitivity
{
    NotGiven = 0,
    VeryHardToTrigger = 10,
    HardToTrigger = 20,
    EasyToTrigger = 30,
    VeryEasyToTrigger = 40,
    NaturallyTriggered = 45,
}

public enum AvalPropagation
{
    NotGiven = 0,
    FewSteepSlopes = 1,
    SomeSteepSlopes = 2,
    ManySteepSlopes = 3,
}
