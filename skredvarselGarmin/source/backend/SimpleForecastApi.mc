import Toybox.Lang;

using Toybox.Time as Time;
using Toybox.Application.Storage;

// Returns [forecast, storedTime] array
(:glance,:background)
public function getSimpleForecastForRegion(regionId as String) as Array? {
  var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

  return Storage.getValue(storageKey);
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

public function loadSimpleForecastForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  $.log("Loading simple forecast for " + regionId);

  var language = $.getForecastLanguage();

  var now = Time.now();
  var start = $.getFormattedDateForApiCall($.subtractDays(now, 2));
  var end = $.getFormattedDateForApiCall($.addDays(now, 2));

  var path = $.getSimpleWarningsPathForRegion(regionId, language, start, end);
  var storageKey = $.getSimpleForecastCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, useQueue);
}
