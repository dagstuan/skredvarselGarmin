import Toybox.Lang;
import Toybox.System;

using Toybox.Time;
using Toybox.Time.Gregorian;

// ForecastType: 0 = simple, 1 = detailed
typedef ReloadDataQueueItem as [String, Numeric];

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _reloadQueue as Array<[String, Numeric]> = [];
  private var _currentData as [String, Numeric]?;

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

    if ($.getUseLocation()) {
      if ($.Debug) {
        $.log(
          "Queueing location forecast reload for background update and/or glance update."
        );
      }

      _reloadQueue.add(["location", 0]);
    } else if ($.Debug) {
      $.log(
        "Not queueing location forecast reload for background update and/or glance update since location is disabled."
      );
    }

    var selectedRegionIds = $.getSelectedRegionIds();

    for (var i = 0; i < selectedRegionIds.size(); i++) {
      var regionId = selectedRegionIds[i];

      _reloadQueue.add([regionId, 0]);

      if (i < 2) {
        _reloadQueue.add([regionId, 1]);
      }
    }

    reloadNextRegion();
  }

  public function onReloadedRegion(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == -403) {
      throw new SkredvarselGarminException("Background reload request returned -403 OOM.");
    }

    if (responseCode == 200) {
      if (responseCode == 200 && _currentData[0].equals("location")) {
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

      _currentData = null;

      var reloadedNextRegion = reloadNextRegion();
      if (reloadedNextRegion == false) {
        Background.exit(true);
      }
    } else {
      Background.exit(false);
    }
  }

  protected function loadDetailedWarningsForRegion() {
    if ($.Debug) {
      $.log(Lang.format("Loading detailed forecast for $1$", [_currentData[0]]));
    }

    var language = $.getForecastLanguage();

    var now = Time.now();
    var start = $.getBackgroundDetailedForecastStartDate(now);
    var regionId = _currentData[0];
    var end = $.getBackgroundDetailedForecastEndDate(now, regionId);

    var path = $.getDetailedWarningsPathForRegion(regionId, language, start, end);
    var storageKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

    $.makeApiRequest(path, storageKey, method(:onReloadedRegion), false);
  }

  private function reloadNextRegion() as Boolean {
    if (_reloadQueue.size() > 0) {
      _currentData = _reloadQueue[0];
      _reloadQueue = _reloadQueue.slice(1, null);

      var regionId = _currentData[0];

      if (regionId.equals("location")) {
        $.loadSimpleForecastForLocation(method(:onReloadedRegion), false);
      } else if (_currentData[1] == 1) {
        loadDetailedWarningsForRegion();
      } else {
        $.loadSimpleForecastForRegion(
          regionId.toString(),
          method(:onReloadedRegion),
          false
        );
      }

      return true;
    }

    return false;
  }
}
