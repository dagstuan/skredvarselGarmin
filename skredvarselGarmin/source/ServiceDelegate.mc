import Toybox.Lang;
import Toybox.System;

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _skredvarselApi as SkredvarselApi;
  private var _skredvarselStorage as SkredvarselStorage;

  private var _regionsToReload as Array<String> = [];

  public function initialize(
    skredvarselApi as SkredvarselApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    ServiceDelegate.initialize();

    _skredvarselApi = skredvarselApi;
    _skredvarselStorage = skredvarselStorage;
  }

  public function onTemporalEvent() as Void {
    $.logMessage("Temporal event triggered. Reloading region data.");

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

    _regionsToReload = _skredvarselStorage.getSelectedRegionIds();

    reloadNextRegion();
  }

  public function onReloadedRegion(data) as Void {
    var reloadedNextRegion = reloadNextRegion();

    if (reloadedNextRegion == false) {
      $.logMessage("Done reloaded regions.");
      Background.exit(true);
    }
  }

  private function reloadNextRegion() as Boolean {
    if (_regionsToReload.size() > 0) {
      var nextRegion = _regionsToReload[0];
      _regionsToReload = _regionsToReload.slice(1, null);

      _skredvarselApi.loadSimpleForecastForRegion(
        nextRegion,
        method(:onReloadedRegion)
      );

      return true;
    }

    return false;
  }
}
