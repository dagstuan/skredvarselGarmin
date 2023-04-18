import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.Time as Time;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

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
  var twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);
  var start = getFormattedDate(now.subtract(twoDays));
  var end = getFormattedDate(now.add(twoDays));

  var path = $.getDetailedWarningsPathForRegion(regionId, language, start, end);
  var storageKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, true);
}
