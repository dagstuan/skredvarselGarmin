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
