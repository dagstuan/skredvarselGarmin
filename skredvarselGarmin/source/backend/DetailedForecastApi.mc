import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

(:background)
public class DetailedForecastApi {
  private var _queue;

  public function initialize(queue as CommandExecutor) {
    _queue = queue;
  }

  // Returns [warning, storedTime] array
  public function getDetailedWarningsForRegion(regionId as String) as Array? {
    var cacheKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

    return Storage.getValue(cacheKey);
  }

  public function loadDetailedWarningsForRegion(
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
      "/detailedWarningsByRegion/" +
      regionId +
      "/1/" +
      getFormattedDate(start) +
      "/" +
      getFormattedDate(end);

    var storageKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

    var delegate = new WebRequestDelegate(_queue, path, storageKey, callback);
    delegate.makeRequest();
  }
}
