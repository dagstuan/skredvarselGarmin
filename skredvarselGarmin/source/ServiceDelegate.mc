import Toybox.System;

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _skredvarselApi;

  private var _regionsToReload = 0;

  public function initialize(skredvarselApi) {
    ServiceDelegate.initialize();

    _skredvarselApi = skredvarselApi;
  }

  public function onTemporalEvent() as Void {
    var regions = $.getSelectedRegionIds();

    _regionsToReload = regions.size();

    for (var i = 0; i < regions.size(); i++) {
      _skredvarselApi.loadForecastForRegion(
        regions[i],
        method(:onReloadedRegion)
      );
    }
  }

  public function onReloadedRegion() {
    System.println("reloaded region");
    _regionsToReload -= 1;

    if (_regionsToReload == 0) {
      Background.exit(true);
    }
  }
}
