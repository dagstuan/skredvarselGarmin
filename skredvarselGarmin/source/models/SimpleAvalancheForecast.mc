import Toybox.Lang;

using Toybox.System;
using Toybox.Time;

(:glance)
public class SimpleAvalancheForecast {
  public var regionId as String;
  public var warnings as Array<SimpleAvalancheWarning>;

  public function initialize(
    regionId as String,
    data as AvalancheForecastData
  ) {
    me.regionId = regionId;

    var numWarnings = data.size();
    me.warnings = new Array<SimpleAvalancheWarning>[numWarnings];

    for (var i = 0; i < numWarnings; i++) {
      me.warnings[i] = new SimpleAvalancheWarning(
        data[i] as AvalancheWarningData
      );
    }
  }

  public function getDangerLevelToday() as Number {
    if (warnings == null || warnings.size() == 0) {
      return 0;
    }

    var now = Time.now();
    for (var i = 0; i < warnings.size(); i++) {
      var warning = warnings[i];
      if (
        now.compare(warning.validFrom) > 0 &&
        now.compare(warning.validTo) <= 0
      ) {
        return warning.dangerLevel;
      }
    }

    return 0;
  }
}
