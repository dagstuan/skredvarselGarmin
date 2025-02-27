import Toybox.Lang;

typedef SimpleAvalancheWarning as {
  "dangerLevel" as Number,
  "validity" as Array,
  "hasEmergency" as Boolean,
};

typedef SimpleAvalancheForecast as Array<SimpleAvalancheWarning>;

typedef LocationAvalancheForecast as {
  "regionId" as Number,
  "warnings" as SimpleAvalancheForecast,
};

typedef SimpleForecastData as SimpleAvalancheForecast or
  LocationAvalancheForecast;

typedef AvalancheProblem as {
  "typeName" as String,
  "exposedHeights" as Array<Number>,
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

typedef SetupSubscriptionResponse as {
  "status" as String,
  "addWatchKey" as String?,
};

typedef CheckAddWatchResponse as {
  "status" as String,
};
