import Toybox.Lang;

using Toybox.Time;

typedef SimpleAvalancheWarning as {
  :dangerLevel as Number,
  :validity as Array,
};

typedef SimpleAvalancheForecast as Array<SimpleAvalancheWarning>;

typedef AvalancheProblem as {
  :typeName as String,
  :exposedHeights as Array<Number>,
  :validExpositions as String,
};
typedef DetailedAvalancheWarning as {
  :dangerLevel as Number,
  :validity as Array,
  :mainText as String,
  :avalancheProblems as Array<AvalancheProblem>,
};
