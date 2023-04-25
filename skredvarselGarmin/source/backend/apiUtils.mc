import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;

(:background)
function getFormattedDateForApiCall(moment as Time.Moment) as String {
  var info = Gregorian.info(moment, Time.FORMAT_SHORT);

  return Lang.format("$1$-$2$-$3$", [
    info.year.format("%04u"),
    info.month.format("%02u"),
    info.day.format("%02u"),
  ]);
}
