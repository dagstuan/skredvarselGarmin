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
  public function getDetailedWarningForRegion(regionId as String) as Array? {
    var cacheKey = $.getDetailedWarningCacheKeyForRegion(regionId);

    return Storage.getValue(cacheKey);
  }

  public function loadDetailedWarningForRegion(
    regionId as String?,
    callback as WebRequestDelegateCallback
  ) {
    if ($.canMakeWebRequest() == false) {
      $.logMessage("No connection available. Skipping loading forecast.");
      return;
    }

    var now = Time.now();

    var path =
      "/detailedWarningByRegion/" + regionId + "/1/" + getFormattedDate(now);

    var storageKey = $.getDetailedWarningCacheKeyForRegion(regionId);

    var delegate = new WebRequestDelegate(_queue, path, storageKey, callback);
    delegate.makeRequest();
  }
}
