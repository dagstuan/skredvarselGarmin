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
function getSimpleWarningsPathForRegion(
  regionId as String,
  language as Number
) as String {
  var now = Time.now();
  var twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);
  var start = now.subtract(twoDays);
  var end = now.add(twoDays);

  return (
    "/simpleWarningsByRegion/" +
    regionId +
    "/" +
    language +
    "/" +
    getFormattedDate(start) +
    "/" +
    getFormattedDate(end)
  );
}

(:background)
public function loadSimpleForecastForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  if ($.Debug) {
    $.logMessage("Loading simple forecast for " + regionId);
  }

  var language = $.getForecastLanguage();
  var path = $.getSimpleWarningsPathForRegion(regionId, language);
  var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, useQueue);
}
