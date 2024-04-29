import Toybox.Lang;
import Toybox.System;

using Toybox.Application.Properties;

typedef ReloadData as {
  "path" as String,
  "storageKey" as String,
};

(:background)
class ServiceDelegate extends System.ServiceDelegate {
  private var _dataToReload as Array<ReloadData> = [];

  // private var _simpleRegionsToReload as Array<String> = [];
  // private var _detailedRegionsToReload as Array<String> = [];

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

    if (Properties.getValue("useLocation")) {
      var location = $.getLocation();

      if (location == null) {
        $.log("No location available. Not reloading location warning.");
      } else {
        _dataToReload.add({
          :path => $.getSimpleWarningsPathForLocation(
            location[0],
            location[1],
            _language,
            _start,
            _end
          ),
          :storageKey => $.simpleForecastCacheKeyForLocation,
        });
      }
    }

    var selectedRegionIds = $.getSelectedRegionIds();

    for (var i = 0; i < selectedRegionIds.size(); i++) {
      var regionId = selectedRegionIds[i];

      _dataToReload.add({
        :path => $.getSimpleWarningsPathForRegion(
          regionId,
          _language,
          _start,
          _end
        ),
        :storageKey => $.getSimpleForecastCacheKeyForRegion(regionId),
      });

      if (i < 2) {
        _dataToReload.add({
          :path => $.getDetailedWarningsPathForRegion(
            regionId,
            _language,
            _start,
            _end
          ),
          :storageKey => $.getDetailedWarningsCacheKeyForRegion(regionId),
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
      var reloadedNextRegion = reloadNextRegion();
      if (reloadedNextRegion == false) {
        Background.exit(true);
      }
    } else {
      Background.exit(false);
    }
  }

  private function reloadNextRegion() as Boolean {
    if (_dataToReload.size() > 0) {
      var nextData = _dataToReload[0];
      _dataToReload = _dataToReload.slice(1, null);

      $.makeApiRequest(
        nextData[:path],
        nextData[:storageKey],
        method(:onReloadedRegion),
        false
      );

      return true;
    }

    return false;
  }
}
