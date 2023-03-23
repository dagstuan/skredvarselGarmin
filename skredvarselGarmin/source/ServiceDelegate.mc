import Toybox.Lang;
import Toybox.System;

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _simpleRegionsToReload as Array<String> = [];
  private var _detailedRegionsToReload as Array<String> = [];

  public function initialize() {
    ServiceDelegate.initialize();
  }

  public function onTemporalEvent() as Void {
    if ($.Debug) {
      $.logMessage("Temporal event triggered. Reloading region data.");
    }

    if ($.canMakeWebRequest() == false) {
      if ($.Debug) {
        $.logMessage("No connection available. Skipping reload.");
      }
      Background.exit(false);
      return;
    }

    var monkeyVersion = $.getMonkeyVersion();
    if (
      monkeyVersion[0] < 4 &&
      !(monkeyVersion[0] >= 3 && monkeyVersion[1] >= 2)
    ) {
      if ($.Debug) {
        $.logMessage(
          "Api version " +
            monkeyVersion[0] +
            "." +
            monkeyVersion[1] +
            "." +
            monkeyVersion[2] +
            ". No API support for modifying store in background. Not refreshing data."
        );
      }
      return;
    }

    var selectedRegionIds = $.getSelectedRegionIds();
    _simpleRegionsToReload = selectedRegionIds;
    _detailedRegionsToReload = selectedRegionIds.slice(0, 2);

    reloadNextRegion();
  }

  public function onReloadedRegion(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    var reloadedNextRegion = reloadNextRegion();

    if (reloadedNextRegion == false) {
      Background.exit(true);
    }
  }

  private function reloadNextRegion() as Boolean {
    var language = $.getForecastLanguage();

    if (_simpleRegionsToReload.size() > 0) {
      var nextRegion = _simpleRegionsToReload[0];
      _simpleRegionsToReload = _simpleRegionsToReload.slice(1, null);

      var path = $.getSimpleWarningsPathForRegion(nextRegion, language);
      var storageKey = $.getSimpleForecastCacheKeyForRegion(nextRegion);
      var delegate = new WebRequestDelegate(
        path,
        storageKey,
        method(:onReloadedRegion)
      );
      delegate.makeRequest();

      return true;
    } else if (_detailedRegionsToReload.size() > 0) {
      var nextRegion = _detailedRegionsToReload[0];
      _detailedRegionsToReload = _detailedRegionsToReload.slice(1, null);

      var path = $.getDetailedWarningsPathForRegion(nextRegion, language);
      var storageKey = $.getDetailedWarningsCacheKeyForRegion(nextRegion);
      var delegate = new WebRequestDelegate(
        path,
        storageKey,
        method(:onReloadedRegion)
      );
      delegate.makeRequest();

      return true;
    }

    return false;
  }
}
