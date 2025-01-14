import Toybox.Lang;
import Toybox.System;

using Toybox.Application.Properties;

var locationRegionId = "location-region";

typedef ReloadDataQueueItem as {
  "regionId" as String?,
  "forecastType" as String,
};

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _reloadQueue as Array<ReloadDataQueueItem> = [];
  private var _currentData as ReloadDataQueueItem?;

  private var _language as Number;
  private var _start as String;
  private var _end as String;

  public function initialize() {
    ServiceDelegate.initialize();

    _language = $.getForecastLanguage();

    var now = Time.now();
    _start = $.getFormattedDateForApiCall($.subtractDays(now, 2));
    _end = $.getFormattedDateForApiCall($.addDays(now, 2));
  }

  public function onTemporalEvent() as Void {
    $.log(
      "Temporal event triggered. Reloading region data and updating complication."
    );

    if ($.getHasSubscription() == false) {
      $.log("No subscription detected. Not reloading.");

      Background.exit(false);
      return;
    }

    $.updateComplicationIfExists();

    if ($.canMakeWebRequest() == false) {
      $.log("No connection available. Skipping reload.");

      Background.exit(false);
      return;
    }

    var deviceSettings = System.getDeviceSettings();
    var monkeyVersion = deviceSettings.monkeyVersion;
    if (
      monkeyVersion[0] < 4 &&
      !(monkeyVersion[0] >= 3 && monkeyVersion[1] >= 2)
    ) {
      $.log(
        Lang.format(
          "Api version $1$.$2$.$3$. No API support for modifying store in background. Not refreshing data.",
          monkeyVersion
        )
      );
      Background.exit(false);
      return;
    }

    if ($.getUseLocation()) {
      var location = $.getLocation();

      if (location == null) {
        $.log("No location available. Not reloading location warning.");
      } else {
        _reloadQueue.add({
          :regionId => locationRegionId,
          :forecastType => "simple",
        });
      }
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

  private function getPath(
    regionId as String,
    forecastType as String
  ) as String {
    if (regionId == locationRegionId) {
      var location = $.getLocation();
      return $.getSimpleWarningsPathForLocation(
        location[0],
        location[1],
        _language,
        _start,
        _end
      );
    }

    return forecastType.equals("simple")
      ? $.getSimpleWarningsPathForRegion(regionId, _language, _start, _end)
      : $.getDetailedWarningsPathForRegion(regionId, _language, _start, _end);
  }

  private function getStorageKey(
    regionId as String,
    forecastType as String
  ) as String {
    return regionId == locationRegionId
      ? $.simpleForecastCacheKeyForLocation
      : forecastType.equals("simple")
      ? $.getSimpleForecastCacheKeyForRegion(regionId)
      : $.getDetailedWarningsCacheKeyForRegion(regionId);
  }

  public function onReloadedRegion(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      if (_currentData[:regionId].equals(locationRegionId)) {
        var regionId = (data as LocationAvalancheForecast)["regionId"];
        $.log(
          Lang.format(
            "Location forecast reloaded. Adding detailed forecast reload for region $1$.",
            [regionId]
          )
        );

        _reloadQueue.add({
          :regionId => regionId,
          :forecastType => "detailed",
        });
      }

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

      var path = getPath(regionId, forecastType);
      var storageKey = getStorageKey(regionId, forecastType);

      $.makeApiRequest(path, storageKey, method(:onReloadedRegion), false);

      return true;
    }

    return false;
  }
}
