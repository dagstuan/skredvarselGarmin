import Toybox.Lang;
import Toybox.System;

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _skredvarselApi as SkredvarselApi;
  private var _skredvarselStorage as SkredvarselStorage;

  private var _regionsToReload = 0;

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

    if (!$.hasPhoneConnection()) {
      $.logMessage("No connection available. Skipping reloading regions.");
      Background.exit(false);
      return;
    }

    var regions = _skredvarselStorage.getSelectedRegionIds();

    _regionsToReload = regions.size();

    for (var i = 0; i < regions.size(); i++) {
      _skredvarselApi.loadSimpleForecastForRegion(
        regions[i],
        method(:onReloadedRegion)
      );
    }
  }

  public function onReloadedRegion(data) as Void {
    _regionsToReload -= 1;

    if (_regionsToReload == 0) {
      $.logMessage("Done reloaded regions.");
      Background.exit(true);
    }
  }
}
