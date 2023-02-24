import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.Time as Time;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

// Returns [forecast, storedTime] array
(:glance)
public function getSimpleForecastForRegion(regionId as String) as Array? {
  var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

  var valueFromStorage = Storage.getValue(storageKey) as Array?;

  if (valueFromStorage != null) {
    return valueFromStorage;
  }

  return null;
}

(:background)
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

  var delegate = new WebRequestDelegate(path, storageKey, callback);
  delegate.makeRequest();
}
