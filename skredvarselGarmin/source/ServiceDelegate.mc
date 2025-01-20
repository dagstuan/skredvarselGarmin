import Toybox.Lang;
import Toybox.System;

using Toybox.Application.Properties;

typedef ReloadDataQueueItem as {
  "regionId" as String?,
  "forecastType" as String,
};

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _reloadQueue as Array<ReloadDataQueueItem> = [];
  private var _currentData as ReloadDataQueueItem?;

  public function initialize() {
    ServiceDelegate.initialize();
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

    var deviceSettings = System.getDeviceSettings();
    var monkeyVersion = deviceSettings.monkeyVersion;
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

    if ($.getUseLocation()) {
      _reloadQueue.add({
        :regionId => "location-region",
        :forecastType => "simple",
      });
    }

    var selectedRegionIds = $.getSelectedRegionIds();

    for (var i = 0; i < selectedRegionIds.size(); i++) {
      var regionId = selectedRegionIds[i];

      _reloadQueue.add({
        :regionId => regionId,
        :forecastType => "simple",
      });

      if (i < 2) {
        _reloadQueue.add({
          :regionId => regionId,
          :forecastType => "detailed",
        });
      }
    }

    reloadNextRegion();
  }

  public function onReloadedRegion(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      if (_currentData[:regionId].equals("location-region")) {
        var regionId = (data as LocationAvalancheForecast)["regionId"];

        if ($.Debug) {
          $.log(
            Lang.format(
              "Location forecast reloaded. Adding detailed forecast reload for region $1$.",
              [regionId]
            )
          );
        }

        _reloadQueue.add({
          :regionId => regionId,
          :forecastType => "detailed",
        });
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

  private function reloadNextRegion() as Boolean {
    if (_reloadQueue.size() > 0) {
      _currentData = _reloadQueue[0];
      _reloadQueue = _reloadQueue.slice(1, null);

      var regionId = _currentData[:regionId];
      var forecastType = _currentData[:forecastType];

      if (regionId.equals("location-region")) {
        $.loadSimpleForecastForLocation(method(:onReloadedRegion), false);
      } else if (forecastType.equals("detailed")) {
        $.loadDetailedWarningsForRegion(
          regionId,
          method(:onReloadedRegion),
          false
        );
      } else {
        $.loadSimpleForecastForRegion(
          regionId,
          method(:onReloadedRegion),
          false
        );
      }

      return true;
    }

    return false;
  }
}
