import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;

function getFormattedTimestamp(moment as Time.Moment) {
  var info = Gregorian.info(moment, Time.FORMAT_SHORT);

  return info.hour.format("%02u") + ":" + info.min.format("%02u");
}

(:background)
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

function _toDayNumber(info as Gregorian.Info) as Number {
  return info.year * 10000 + info.month * 100 + info.day;
}

function isToday(shortInfo as Gregorian.Info) {
  var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
  return _toDayNumber(shortInfo) == _toDayNumber(today);
}

function isYesterday(shortInfo as Gregorian.Info) {
  var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
  var infoNum = _toDayNumber(shortInfo);
  // Build yesterday's date by constructing a moment at noon of today then subtracting a day
  var todayNoon = Gregorian.moment({
    :year => today.year,
    :month => today.month,
    :day => today.day,
    :hour => 12,
    :minute => 0,
    :second => 0,
  });
  var yesterdayInfo = Gregorian.info(
    todayNoon.subtract(new Time.Duration(Gregorian.SECONDS_PER_DAY)),
    Time.FORMAT_SHORT
  );
  return infoNum == _toDayNumber(yesterdayInfo);
}

function isTomorrow(shortInfo as Gregorian.Info) {
  var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
  var infoNum = _toDayNumber(shortInfo);
  var todayNoon = Gregorian.moment({
    :year => today.year,
    :month => today.month,
    :day => today.day,
    :hour => 12,
    :minute => 0,
    :second => 0,
  });
  var tomorrowInfo = Gregorian.info(
    todayNoon.add(new Time.Duration(Gregorian.SECONDS_PER_DAY)),
    Time.FORMAT_SHORT
  );
  return infoNum == _toDayNumber(tomorrowInfo);
}

function getHumanReadableDateText(date as Time.Moment) as String {
  var info = Gregorian.info(date, Time.FORMAT_SHORT);
  if ($.isToday(info)) {
    return $.getOrLoadResourceString("I dag", :Today);
  } else if ($.isYesterday(info)) {
    return $.getOrLoadResourceString("I går", :Yesterday);
  } else if ($.isTomorrow(info)) {
    return $.getOrLoadResourceString("I morgen", :Tomorrow);
  } else {
    var useWatchLanguage = $.getUseWatchLanguage();
    if (useWatchLanguage) {
      var validityInfo = Gregorian.info(date, Time.FORMAT_MEDIUM);
      return Lang.format("$1$. $2$", [validityInfo.day, validityInfo.month]);
    } else {
      var validityInfo = Gregorian.info(date, Time.FORMAT_SHORT);
      return Lang.format("$1$. $2$", [
        validityInfo.day,
        getNorwegianMonthShort(validityInfo.month),
      ]);
    }
  }
}

function getNorwegianMonthShort(monthNum as Number) {
  return [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mai",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ][monthNum - 1];
}
