import Toybox.Lang;

using Toybox.System;

(:glance)
public class AvalancheForecast {
  public var regionId as String;
  public var warnings as Array<AvalancheWarning>;

  public function initialize(
    regionId as String,
    data as AvalancheForecastData
  ) {
    me.regionId = regionId;

    var numWarnings = data.size();
    me.warnings = new Array<AvalancheWarning>[numWarnings];

    for (var i = 0; i < numWarnings; i++) {
      me.warnings[i] = new AvalancheWarning(data[i] as AvalancheWarningData);
    }
  }
}
