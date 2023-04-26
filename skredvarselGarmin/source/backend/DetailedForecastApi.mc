import Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Time;

// Returns [warning, storedTime] array
function getDetailedWarningsForRegion(regionId as String) as Array? {
  var cacheKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

  return Storage.getValue(cacheKey);
}

(:background)
function getDetailedWarningsPathForRegion(
  regionId as String,
  language as Number,
  formattedStartDate as String,
  formattedEndDate as String
) as String {
  return (
    "/detailedWarningsByRegion/" +
    regionId +
    "/" +
    language +
    "/" +
    formattedStartDate +
    "/" +
    formattedEndDate
  );
}

function loadDetailedWarningsForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback
) {
  $.log("Loading detailed forecast for " + regionId);

  var language = $.getForecastLanguage();

  var now = Time.now();
  var start = $.getFormattedDateForApiCall($.subtractDays(now, 2));
  var end = $.getFormattedDateForApiCall($.addDays(now, 2));

  var path = $.getDetailedWarningsPathForRegion(regionId, language, start, end);
  var storageKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, true);
}
