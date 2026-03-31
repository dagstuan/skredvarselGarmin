import Toybox.Lang;

typedef AvalancheProblem as {
  "typeId" as Number,
  "exposedHeights" as Array<Number>?,
  "exposedHeightZones" as Array<Boolean>?,
  "validExpositions" as String,
  "dangerLevel" as Number,
};

typedef DetailedAvalancheWarning as {
  "published" as String,
  "dangerLevel" as Number,
  "validity" as Array,
  "mainText" as String,
  "avalancheProblems" as Array<AvalancheProblem>,
  "isTendency" as Boolean,
  "emergencyWarning" as String?,
  "destructiveSize" as Number,
};

typedef DetailedWarningsForLocationResponse as {
  "regionId" as String,
  "warnings" as Array<DetailedAvalancheWarning>,
};

typedef SetupSubscriptionResponse as {
  "status" as String,
  "addWatchKey" as String?,
};

typedef CheckAddWatchResponse as {
  "status" as String,
};
