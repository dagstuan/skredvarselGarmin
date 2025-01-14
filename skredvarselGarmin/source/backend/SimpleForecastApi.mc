import Toybox.Lang;

using Toybox.Time as Time;
using Toybox.Application.Storage;

// Returns [forecast, storedTime] array
(:glance,:background)
public function getSimpleForecastForRegion(regionId as String) as Array? {
  var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

  return Storage.getValue(storageKey) as Array?;
}

(:background)
function getSimpleWarningsPathForRegion(
  regionId as String,
  language as Number,
  formattedStartDate as String,
  formattedEndDate as String
) as String {
  return Lang.format("/simpleWarningsByRegion/$1$/$2$/$3$/$4$", [
    regionId,
    language,
    formattedStartDate,
    formattedEndDate,
  ]);
}

public function loadSimpleForecastForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  $.log(Lang.format("Loading simple forecast for $1$", [regionId]));

  var language = $.getForecastLanguage();

  var now = Time.now();
  var start = $.getFormattedDateForApiCall($.subtractDays(now, 2));
  var end = $.getFormattedDateForApiCall($.addDays(now, 2));

  var path = $.getSimpleWarningsPathForRegion(regionId, language, start, end);
  var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, useQueue);
}

(:background)
function getSimpleWarningsPathForLocation(
  latitude as Double,
  longitude as Double,
  language as Number,
  formattedStartDate as String,
  formattedEndDate as String
) as String {
  return Lang.format("/simpleWarningsByLocation/$1$/$2$/$3$/$4$/$5$", [
    latitude,
    longitude,
    language,
    formattedStartDate,
    formattedEndDate,
  ]);
}

// Returns [forecast, storedTime] array
(:glance,:background)
public function getSimpleForecastForLocation() as Array? {
  var storageKey = $.simpleForecastCacheKeyForLocation;

  return Storage.getValue(storageKey) as Array?;
}

public function loadSimpleForecastForLocation(
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  $.log("Loading simple forecast for location..");

  var language = $.getForecastLanguage();
  var location = $.getLocation();

  if (location == null) {
    $.log("No location available. Not reloading location warning.");
    return;
  }

  var now = Time.now();
  var start = $.getFormattedDateForApiCall($.subtractDays(now, 2));
  var end = $.getFormattedDateForApiCall($.addDays(now, 2));

  var path = $.getSimpleWarningsPathForLocation(
    location[0],
    location[1],
    language,
    start,
    end
  );
  var storageKey = $.simpleForecastCacheKeyForLocation;

  $.makeApiRequest(path, storageKey, callback, useQueue);
}
