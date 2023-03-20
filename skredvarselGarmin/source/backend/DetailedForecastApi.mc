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
function getDetailedWarningsPathForRegion(regionId as String) as String {
  var now = Time.now();

  var twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);
  var start = now.subtract(twoDays);
  var end = now.add(twoDays);

  return (
    "/detailedWarningsByRegion/" +
    regionId +
    "/1/" +
    getFormattedDate(start) +
    "/" +
    getFormattedDate(end)
  );
}

function loadDetailedWarningsForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback
) {
  if ($.Debug) {
    $.logMessage("Loading detailed forecast for " + regionId);
  }

  var path = $.getDetailedWarningsPathForRegion(regionId);
  var storageKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, true);
}
