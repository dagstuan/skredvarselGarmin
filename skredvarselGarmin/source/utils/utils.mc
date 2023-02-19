import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Math;

const DrawOutlines = false;

(:background)
const Regions = {
  "3006" => "Finnmarkskysten",
  "3032" => "Hallingdal",
  "3034" => "Hardanger",
  "3037" => "Heiane",
  "3018" => "Helgeland",
  "3027" => "Indre Fjordane",
  "3029" => "Indre Sogn",
  "3013" => "Indre Troms",
  "3028" => "Jotunheimen",
  "3014" => "Lofoten og Vesterålen",
  "3010" => "Lyngen",
  "3009" => "Nord-Troms",
  "3003" => "Nordenskiöld Land",
  "3015" => "Ofoten",
  "3023" => "Romsdal",
  "3016" => "Salten",
  "3024" => "Sunnmøre",
  "3017" => "Svartisen",
  "3012" => "Sør-Troms",
  "3022" => "Trollheimen",
  "3011" => "Tromsø",
  "3007" => "Vest-Finnmark",
  "3035" => "Vest-Telemark",
  "3031" => "Voss",
};

(:background)
function canMakeWebRequest() as Boolean {
  var deviceSettings = System.getDeviceSettings();
  var connectionInfo = deviceSettings.connectionInfo;

  var bluetoothState = connectionInfo[:bluetooth][:state];
  if (bluetoothState.equals(System.CONNECTION_STATE_CONNECTED)) {
    return true;
  }

  return false;
}

(:background)
function getMonkeyVersion() as Array<Number> {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.monkeyVersion;
}

function getDeviceScreenWidth() as Number {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.screenWidth;
}

(:glance)
function colorize(dangerLevel as Number) as Gfx.ColorType {
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
  var info = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);

  var formattedTime = Lang.format("$1$:$2$:$3$ $4$ $5$ $6$ $7$", [
    info.hour < 10 ? "0" + info.hour : info.hour,
    info.min < 10 ? "0" + info.min : info.min,
    info.sec < 10 ? "0" + info.sec : info.sec,
    info.day_of_week,
    info.day,
    info.month,
    info.year,
  ]);

  System.println(formattedTime + " - " + message);
}

const halfWidthDangerLevelIcon = 20;

function getIconResourceForDangerLevel(dangerLevel as Number) {
  if (dangerLevel == 1) {
    return $.Rez.Drawables.Level1;
  } else if (dangerLevel == 2) {
    return $.Rez.Drawables.Level2;
  } else if (dangerLevel == 3) {
    return $.Rez.Drawables.Level3;
  } else if (dangerLevel == 4 || dangerLevel == 5) {
    return $.Rez.Drawables.Level4_5;
  }

  return $.Rez.Drawables.NoLevel;
}

function getScreenWidthAtPoint(deviceScreenWidth as Numeric, y as Numeric) {
  var radius = deviceScreenWidth / 2;
  return (
    2 *
    radius *
    Math.sin(
      Math.toRadians(2 * Math.toDegrees(Math.acos(1 - y.toFloat() / radius))) /
        2
    )
  ).toNumber();
}

function drawOutline(
  dc as Gfx.Dc,
  x0 as Numeric,
  y0 as Numeric,
  width as Numeric,
  height as Numeric
) {
  if (!$.DrawOutlines) {
    return;
  }

  dc.setPenWidth(1);
  dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

  dc.drawRectangle(x0, y0, width, height);
}

function min(a as Numeric, b as Numeric) {
  return a < b ? a : b;
}
