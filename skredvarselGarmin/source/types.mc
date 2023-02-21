import Toybox.Lang;

using Toybox.Time;

typedef SimpleAvalancheWarning as {
  :dangerLevel as Number,
  :validFrom as String,
  :validTo as String,
  :validity as Array,
};

typedef SimpleAvalancheForecast as Array<SimpleAvalancheWarning>;

typedef DetailedAvalancheWarningData as Dictionary<String, String>?;
