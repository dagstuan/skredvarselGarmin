import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

(:background)
public class SimpleForecastApi {
  private var _queue as CommandExecutor;

  public function initialize(queue as CommandExecutor) {
    _queue = queue;
  }

  // Returns [forecast, storedTime] array
  public function getSimpleForecastForRegion(regionId as String) as Array? {
    $.logMessage("Reading storage");

    var valueFromStorage =
      Storage.getValue($.getSimpleForecastCacheKeyForRegion(regionId)) as
      Array?;

    if (valueFromStorage != null) {
      var forecast = valueFromStorage[0] as SimpleAvalancheForecast;

      for (var i = 0; i < forecast.size(); i++) {
        var warning = forecast[i];

        warning["validity"] = [
          $.parseDate(warning["validFrom"]),
          $.parseDate(warning["validTo"]),
        ];
        warning.remove("validFrom");
        warning.remove("validTo");
      }

      // TODO CLEAN!
      return valueFromStorage;
    }

    return null;
  }

  public function loadSimpleForecastForRegion(
    regionId as String?,
    callback as WebRequestDelegateCallback
  ) {
    if ($.canMakeWebRequest() == false) {
      $.logMessage("No connection available. Skipping loading forecast.");
      return;
    }

    var now = Time.now();
    var twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);
    var start = now.subtract(twoDays);
    var end = now.add(twoDays);

    var path =
      "/simpleWarningsByRegion/" +
      regionId +
      "/1/" +
      getFormattedDate(start) +
      "/" +
      getFormattedDate(end);

    var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

    var delegate = new WebRequestDelegate(_queue, path, storageKey, callback);
    delegate.makeRequest();
  }
}
