import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;

(:background)
function dayDuration(numDays as Number) as Time.Duration {
  return new Time.Duration(Gregorian.SECONDS_PER_DAY * numDays);
}

(:background)
function addDays(moment as Time.Moment, numDays as Number) {
  return moment.add($.dayDuration(numDays));
}

(:background)
function subtractDays(moment as Time.Moment, numDays as Number) {
  return moment.subtract($.dayDuration(numDays));
}

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
    $.subtractDays(Time.today(), 1),
    Time.FORMAT_SHORT
  );

  return (
    shortInfo.day == yesterday.day &&
    shortInfo.month == yesterday.month &&
    shortInfo.year == yesterday.year
  );
}

function isTomorrow(shortInfo as Gregorian.Info) {
  var tomorrow = Gregorian.info($.addDays(Time.today(), 1), Time.FORMAT_SHORT);

  return (
    shortInfo.day == tomorrow.day &&
    shortInfo.month == tomorrow.month &&
    shortInfo.year == tomorrow.year
  );
}

function getHumanReadableDateText(date as Time.Moment) {
  var info = Gregorian.info(date, Time.FORMAT_SHORT);

  if ($.isToday(info)) {
    return $.getOrLoadResourceString("I dag", :Today);
  } else if ($.isYesterday(info)) {
    return $.getOrLoadResourceString("I går", :Yesterday);
  } else if ($.isTomorrow(info)) {
    return $.getOrLoadResourceString("I morgen", :Tomorrow);
  } else {
    var validityInfo = Gregorian.info(date, Time.FORMAT_MEDIUM);

    return Lang.format("$1$. $2$", [validityInfo.day, validityInfo.month]);
  }
}
