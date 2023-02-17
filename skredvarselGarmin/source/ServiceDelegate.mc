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
    $.logMessage("Temporal event triggered.");

    if (!$.hasPhoneConnection()) {
      $.logMessage("No connection available. Skipping loading forecast.");
      Background.exit(false);
      return;
    }

    var regions = _skredvarselStorage.getSelectedRegionIds();

    _regionsToReload = regions.size();

    for (var i = 0; i < regions.size(); i++) {
      _skredvarselApi.loadForecastForRegion(
        regions[i],
        method(:onReloadedRegion)
      );
    }
  }

  public function onReloadedRegion() as Void {
    $.logMessage("reloaded region");
    _regionsToReload -= 1;

    if (_regionsToReload == 0) {
      Background.exit(true);
    }
  }
}
