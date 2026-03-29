import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;

(:background)
function getFormattedDateForApiCall(moment as Time.Moment) as String {
  var info = Gregorian.info(moment, Time.FORMAT_SHORT);

  return (
    info.year.format("%04u") +
    "-" +
    info.month.format("%02u") +
    "-" +
    info.day.format("%02u")
  );
}

(:background)
function getForecastEndDateForApiCall(
  now as Time.Moment,
  regionId as String?
) as String {
  var endOffset = 2;

  if (regionId != null && $.isSwedishRegion(regionId)) {
    endOffset = 3;
  }

  return $.getFormattedDateForApiCall($.addDays(now, endOffset));
}

// Returns start/end dates for a background detailed forecast fetch.
// On memory-limited devices, only fetch today or tomorrow (single day).
(:background,:limitedBackgroundMemory)
function getBackgroundDetailedForecastStartDate(now as Time.Moment) as String {
  var nowInfo = Gregorian.info(now, Time.FORMAT_SHORT);
  var targetDay = nowInfo.hour >= $.NEXT_DAY_FORECAST_HOUR ? $.addDays(now, 1) : now;
  return $.getFormattedDateForApiCall(targetDay);
}

(:background,:noLimitedBackgroundMemory)
function getBackgroundDetailedForecastStartDate(now as Time.Moment) as String {
  return $.getFormattedDateForApiCall($.subtractDays(now, 2));
}

(:background,:limitedBackgroundMemory)
function getBackgroundDetailedForecastEndDate(
  now as Time.Moment,
  regionId as String?
) as String {
  var nowInfo = Gregorian.info(now, Time.FORMAT_SHORT);
  var targetDay = nowInfo.hour >= $.NEXT_DAY_FORECAST_HOUR ? $.addDays(now, 1) : now;
  return $.getFormattedDateForApiCall(targetDay);
}

(:background,:noLimitedBackgroundMemory)
function getBackgroundDetailedForecastEndDate(
  now as Time.Moment,
  regionId as String?
) as String {
  return $.getForecastEndDateForApiCall(now, regionId);
}
