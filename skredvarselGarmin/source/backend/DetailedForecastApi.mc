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
  formattedEndDate as String,
  includeSnowpackAndWeather as Boolean
) as String {
  var query = includeSnowpackAndWeather
    ? "?includeSnowpackAndWeather=true"
    : "";

  if ($.isSwedishRegion(regionId)) {
    return (
      "/se/detailedWarningsByRegion/" +
      $.getSwedishNumericRegionId(regionId) +
      "/" +
      formattedStartDate +
      "/" +
      formattedEndDate +
      query
    );
  }

  return (
    "/detailedWarningsByRegion/" +
    regionId +
    "/" +
    language +
    "/" +
    formattedStartDate +
    "/" +
    formattedEndDate +
    query
  );
}

function loadDetailedWarningsForRegion(
  regionId as String?,
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  if ($.Debug) {
    $.log(Lang.format("Loading detailed forecast for $1$", [regionId]));
  }

  var language = $.getForecastLanguage();

  var now = $.getNow();
  var start = $.getFormattedDateForApiCall($.subtractDays(now, 2));
  var end = $.getForecastEndDateForApiCall(now, regionId);

  var path = $.getDetailedWarningsPathForRegion(
    regionId,
    language,
    start,
    end,
    $.fetchSnowpackAndWeather()
  );
  var storageKey = $.getDetailedWarningsCacheKeyForRegion(regionId);

  $.makeApiRequest(path, storageKey, callback, useQueue);
}
