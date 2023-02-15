import Toybox.Lang;

using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Math;

(:background)
const Regions = {
  "3003" => "Nordenskiöld Land",
  "3006" => "Finnmarkskysten",
  "3007" => "Vest-Finnmark",
  "3009" => "Nord-Troms",
  "3010" => "Lyngen",
  "3011" => "Tromsø",
  "3012" => "Sør-Troms",
  "3013" => "Indre Troms",
  "3014" => "Lofoten og Vesterålen",
  "3015" => "Ofoten",
  "3016" => "Salten",
  "3017" => "Svartisen",
  "3018" => "Helgeland",
  "3022" => "Trollheimen",
  "3023" => "Romsdal",
  "3024" => "Sunnmøre",
  "3027" => "Indre Fjordane",
  "3028" => "Jotunheimen",
  "3029" => "Indre Sogn",
  "3031" => "Voss",
  "3032" => "Hallingdal",
  "3034" => "Hardanger",
  "3035" => "Vest-Telemark",
  "3037" => "Heiane",
};

(:glance)
function colorize(dangerLevel as Number) as Graphics.ColorType {
  if (dangerLevel == 1) {
    return 0x00ff00;
  } else if (dangerLevel == 2) {
    return 0xffff55;
  } else if (dangerLevel == 3) {
    return 0xffaa00;
  } else if (dangerLevel == 4) {
    return 0xff0000;
  } else if (dangerLevel == 5) {
    return 0x550000;
  } else {
    return 0xaaaaaa;
  }
}

(:background)
function getFormattedDate(moment as Time.Moment) as String {
  var info = Gregorian.utcInfo(moment, Time.FORMAT_SHORT);

  return Lang.format("$1$-$2$-$3$", [
    info.year.format("%04u"),
    info.month.format("%02u"),
    info.day.format("%02u"),
  ]);
}

(:background)
function getFormattedTime(moment as Time.Moment) as String {
  var info = Gregorian.utcInfo(moment, Time.FORMAT_MEDIUM);

  return Lang.format("$1$:$2$:$3$ $4$ $5$ $6$ $7$", [
    info.hour < 10 ? "0" + info.hour : info.hour,
    info.min < 10 ? "0" + info.min : info.min,
    info.sec < 10 ? "0" + info.sec : info.sec,
    info.day_of_week,
    info.day,
    info.month,
    info.year,
  ]);
}

(:glance)
function parseDate(dateString as String) as Time.Moment {
  return Gregorian.moment({
    :year => dateString.substring(0, 4).toNumber(),
    :month => dateString.substring(5, 7).toNumber(),
    :day => dateString.substring(8, 10).toNumber(),
    :hour => dateString.substring(11, 13).toNumber(),
    :minute => dateString.substring(14, 16).toNumber(),
    :second => dateString.substring(17, 19).toNumber(),
  });
}

function arrayContainsString(arr as Array<String>, str as String) {
  for (var i = 0; i < arr.size(); i++) {
    if (arr[i].equals(str)) {
      return true;
    }
  }

  return false;
}

function addToArray(curArray as Array, newValue) {
  var curSize = curArray.size();
  var newArray = new [curSize + 1];
  for (var i = 0; i < curSize; i++) {
    newArray[i] = curArray[i];
  }
  newArray[curSize] = newValue;
  return newArray;
}

function removeStringFromArray(curArray as Array<String>, value as String) {
  if (arrayContainsString(curArray, value)) {
    var curSize = curArray.size();
    var newArray = new [curSize - 1];

    var j = 0;
    for (var i = 0; i < curSize; i++) {
      var elem = curArray[i];
      if (elem.equals(value)) {
        continue;
      }

      newArray[j] = elem;
      j++;
    }
    return newArray;
  }

  return curArray;
}

(:background)
public function logMessage(message as String) {
  System.println($.getFormattedTime(Time.now()) + " - " + message);
}

const halfWidthDangerLevelIcon = 20;

function getIconResourceForDangerLevel(dangerLevel as Number) {
  switch (dangerLevel) {
    case 1:
      return $.Rez.Drawables.Level1;
    case 2:
      return $.Rez.Drawables.Level2;
    case 3:
      return $.Rez.Drawables.Level3;
    case 4:
    case 5:
      return $.Rez.Drawables.Level4_5;
    default:
      return $.Rez.Drawables.NoLevel;
  }
}
