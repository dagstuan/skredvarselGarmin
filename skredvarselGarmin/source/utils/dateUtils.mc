import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;

function getFormattedTimestamp(moment as Time.Moment) {
  var info = Gregorian.info(moment, Time.FORMAT_SHORT);

  return Lang.format("$1$:$2$", [
    info.hour.format("%02u"),
    info.min.format("%02u"),
  ]);
}

(:glance,:background)
function parseDate(dateString as String) as Time.Moment {
  var utcMoment = Gregorian.moment({
    :year => dateString.substring(0, 4).toNumber(),
    :month => dateString.substring(5, 7).toNumber(),
    :day => dateString.substring(8, 10).toNumber(),
    :hour => dateString.substring(11, 13).toNumber(),
    :minute => dateString.substring(14, 16).toNumber(),
    :second => dateString.substring(17, 19).toNumber(),
  });

  var timeZoneOffsetDuration = Gregorian.duration({
    :seconds => System.getClockTime().timeZoneOffset,
  });

  return utcMoment.subtract(timeZoneOffsetDuration);
}

function isToday(shortInfo as Gregorian.Info) {
  var today = Gregorian.info(Time.today(), Time.FORMAT_SHORT);

  return (
    shortInfo.day == today.day &&
    shortInfo.month == today.month &&
    shortInfo.year == today.year
  );
}

function isYesterday(shortInfo as Gregorian.Info) {
  var yesterday = Gregorian.info(
    Time.today().subtract(new Time.Duration(Gregorian.SECONDS_PER_DAY)),
    Time.FORMAT_SHORT
  );

  return (
    shortInfo.day == yesterday.day &&
    shortInfo.month == yesterday.month &&
    shortInfo.year == yesterday.year
  );
}

function isTomorrow(shortInfo as Gregorian.Info) {
  var tomorrow = Gregorian.info(
    Time.today().add(new Time.Duration(Gregorian.SECONDS_PER_DAY)),
    Time.FORMAT_SHORT
  );

  return (
    shortInfo.day == tomorrow.day &&
    shortInfo.month == tomorrow.month &&
    shortInfo.year == tomorrow.year
  );
}
