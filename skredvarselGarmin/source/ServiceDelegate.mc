import Toybox.Lang;
import Toybox.System;

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _simpleForecastApi as SimpleForecastApi;
  private var _detailedForecastApi as DetailedForecastApi;

  private var _simpleRegionsToReload as Array<String> = [];
  private var _detailedRegionsToReload as Array<String> = [];

  public function initialize(
    simpleForecastApi as SimpleForecastApi,
    detailedForecastApi as DetailedForecastApi
  ) {
    ServiceDelegate.initialize();

    _simpleForecastApi = simpleForecastApi;
    _detailedForecastApi = detailedForecastApi;
  }

  public function onTemporalEvent() as Void {
    $.logMessage("Temporal event triggered. Reloading region data.");

    if ($.canMakeWebRequest() == false) {
      $.logMessage("No connection available. Skipping reload.");
      Background.exit(false);
      return;
    }

    var monkeyVersion = $.getMonkeyVersion();
    if (
      monkeyVersion[0] < 4 &&
      !(monkeyVersion[0] >= 3 && monkeyVersion[1] >= 2)
    ) {
      $.logMessage(
        "Api version " +
          monkeyVersion[0] +
          "." +
          monkeyVersion[1] +
          "." +
          monkeyVersion[2] +
          ". No API support for modifying store in background. Not refreshing data."
      );
      return;
    }

    var selectedRegionIds = $.getSelectedRegionIds();
    _simpleRegionsToReload = selectedRegionIds;
    _detailedRegionsToReload = selectedRegionIds.slice(0, 2);

    reloadNextRegion();
  }

  public function onReloadedRegion(data) as Void {
    var reloadedNextRegion = reloadNextRegion();

    if (reloadedNextRegion == false) {
      Background.exit(true);
    }
  }

  private function reloadNextRegion() as Boolean {
    if (_simpleRegionsToReload.size() > 0) {
      var nextRegion = _simpleRegionsToReload[0];
      _simpleRegionsToReload = _simpleRegionsToReload.slice(1, null);

      _simpleForecastApi.loadSimpleForecastForRegion(
        nextRegion,
        method(:onReloadedRegion)
      );

      return true;
    } else if (_detailedRegionsToReload.size() > 0) {
      var nextRegion = _detailedRegionsToReload[0];
      _detailedRegionsToReload = _detailedRegionsToReload.slice(1, null);

      _detailedForecastApi.loadDetailedWarningForRegion(
        nextRegion,
        method(:onReloadedRegion)
      );

      return true;
    }

    return false;
  }
}
