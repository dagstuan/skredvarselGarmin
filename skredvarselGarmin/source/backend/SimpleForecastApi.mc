import Toybox.Lang;

using Toybox.Time as Time;
using Toybox.Application.Storage;

// Returns [forecast, storedTime] array
(:background)
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
  return (
    "/simpleWarningsByRegion/" +
    regionId +
    "/" +
    language +
    "/" +
    formattedStartDate +
    "/" +
    formattedEndDate
  );
}

(:background)
public function loadSimpleForecastForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  if ($.Debug) {
    $.log(Lang.format("Loading simple forecast for $1$", [regionId]));
  }

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
  return (
    "/simpleWarningsByLocation/" +
    latitude +
    "/" +
    longitude +
    "/" +
    language +
    "/" +
    formattedStartDate +
    "/" +
    formattedEndDate
  );
}

// Returns [forecast, storedTime] array
(:background)
public function getSimpleForecastForLocation() as Array? {
  return Storage.getValue("location_simple_forecast") as Array?;
}

(:background)
public function loadSimpleForecastForLocation(
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  if ($.Debug) {
    $.log("Loading simple forecast for location..");
  }

  var location = $.getLocation();

  if (location == null) {
    if ($.Debug) {
      $.log("No location available. Not reloading location warning.");
    }
    return;
  }

  var now = Time.now();

  $.makeApiRequest(
    $.getSimpleWarningsPathForLocation(
      location[0],
      location[1],
      $.getForecastLanguage(),
      $.getFormattedDateForApiCall($.subtractDays(now, 2)),
      $.getFormattedDateForApiCall($.addDays(now, 2))
    ),
    "location_simple_forecast",
    callback,
    useQueue
  );
}
