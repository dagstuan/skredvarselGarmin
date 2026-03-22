import Toybox.Lang;
import Toybox.System;

// ForecastType: 0 = simple, 1 = detailed
typedef ReloadDataQueueItem as [String, Numeric];

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _reloadQueue as Array<[String, Numeric]> = [];
  private var _currentData as [String, Numeric]?;

  public function initialize() {
    ServiceDelegate.initialize();
  }

  private function queueLowMemoryBackgroundReload() as Void {
    var favoriteRegionId = $.getFavoriteRegionId();

    if (favoriteRegionId != null) {
      _reloadQueue.add([favoriteRegionId, 0]);
    }
  }

  (:fullBackgroundReload,:loadLocationForecastOnGlance)
  protected function queueLocationForecastReload() as Void {
    if ($.getUseLocation()) {
      _reloadQueue.add(["location", 0]);
    }
  }

  (:fullBackgroundReload)
  protected function queueFullBackgroundReload() as Void {
    if (self has :queueLocationForecastReload) {
      queueLocationForecastReload();
    }

    var selectedRegionIds = $.getSelectedRegionIds();

    for (var i = 0; i < selectedRegionIds.size(); i++) {
      var regionId = selectedRegionIds[i];

      _reloadQueue.add([regionId, 0]);

      if (i < 2) {
        _reloadQueue.add([regionId, 1]);
      }
    }
  }

  public function onTemporalEvent() as Void {
    if ($.Debug) {
      $.log(
        "Temporal event triggered. Reloading region data and updating complication."
      );
    }

    if ($.getHasSubscription() == false) {
      if ($.Debug) {
        $.log("No subscription detected. Not reloading.");
      }

      Background.exit(false);
      return;
    }

    $.updateComplicationIfExists();

    if ($.canMakeWebRequest() == false) {
      if ($.Debug) {
        $.log("No connection available. Skipping reload.");
      }

      Background.exit(false);
      return;
    }

    var monkeyVersion = System.getDeviceSettings().monkeyVersion;
    if (
      monkeyVersion[0] < 4 &&
      !(monkeyVersion[0] >= 3 && monkeyVersion[1] >= 2)
    ) {
      if ($.Debug) {
        $.log(
          Lang.format(
            "Api version $1$.$2$.$3$. No API support for modifying store in background. Not refreshing data.",
            monkeyVersion
          )
        );
      }
      Background.exit(false);
      return;
    }

    if (self has :queueFullBackgroundReload) {
      queueFullBackgroundReload();
    } else {
      queueLowMemoryBackgroundReload();
    }

    reloadNextRegion();
  }

  (:fullBackgroundReload)
  protected function handleFullBackgroundReload(
    data as WebRequestCallbackData
  ) as Void {
    var regionId = _currentData[0];

    if (regionId.equals("location")) {
      var locationRegionId = (data as LocationAvalancheForecast)["regionId"].toString();

      if ($.Debug) {
        $.log(
          Lang.format(
            "Location forecast reloaded. Adding detailed forecast reload for region $1$.",
            [locationRegionId]
          )
        );
      }

      _reloadQueue.add([locationRegionId, 1]);
    }
  }

  public function onReloadedRegion(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200 || responseCode == -403) {
      if (self has :handleFullBackgroundReload) {
        if (responseCode == 200) {
          handleFullBackgroundReload(data);
        }
      }

      if ($.Debug && responseCode == -403) {
        $.log("Background reload request returned -403. Continuing with next item.");
      }

      _currentData = null;

      var reloadedNextRegion = reloadNextRegion();
      if (reloadedNextRegion == false) {
        Background.exit(true);
      }
    } else {
      Background.exit(false);
    }
  }

  (:fullBackgroundReload)
  protected function reloadNextFullBackgroundRegion() as Void {
    var regionId = _currentData[0];

    if (regionId.equals("location")) {
      $.loadSimpleForecastForLocation(method(:onReloadedRegion), false);
    } else if (_currentData[1] == 1) {
      $.loadDetailedWarningsForRegion(
        regionId.toString(),
        method(:onReloadedRegion),
        false
      );
    } else {
      $.loadSimpleForecastForRegion(
        regionId.toString(),
        method(:onReloadedRegion),
        false
      );
    }
  }

  private function reloadNextRegion() as Boolean {
    if (_reloadQueue.size() > 0) {
      _currentData = _reloadQueue[0];
      _reloadQueue = _reloadQueue.slice(1, null);

      if (self has :reloadNextFullBackgroundRegion) {
        reloadNextFullBackgroundRegion();
      } else {
        $.loadSimpleForecastForRegion(
          _currentData[0].toString(),
          method(:onReloadedRegion),
          false
        );
      }

      return true;
    }

    return false;
  }
}
