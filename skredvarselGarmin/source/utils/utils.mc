import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Math;

const DrawOutlines = false;

(:background)
function getRegions() as Dictionary<String, String> {
  return {
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
}

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

function getDeviceScreenHeight() as Number {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.screenHeight;
}

(:background)
function getAppColorPalette() as Array {
  return [
    // First five indices correspond to danger levels.
    0xaaaaaa,
    0x00ff00,
    0xffff55,
    0xffaa00,
    0xff0000,
    0x550000,
    Graphics.COLOR_WHITE,
    Graphics.COLOR_BLACK,
    Graphics.COLOR_TRANSPARENT,
  ];
}

(:glance)
function colorize(dangerLevel as Number) as Graphics.ColorType {
  var colorPalette = $.getAppColorPalette();
  if (dangerLevel < 0 || dangerLevel > 5) {
    return colorPalette[0];
  }

  return colorPalette[dangerLevel];
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

function isToday(moment as Time.Moment) {
  var info = Gregorian.info(moment, Time.FORMAT_SHORT);
  var today = Gregorian.info(Time.today(), Time.FORMAT_SHORT);

  return (
    info.day == today.day &&
    info.month == today.month &&
    info.year == today.year
  );
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
  dc as Graphics.Dc,
  x0 as Numeric,
  y0 as Numeric,
  width as Numeric,
  height as Numeric
) {
  if (!$.DrawOutlines) {
    return;
  }

  dc.setPenWidth(1);
  dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

  dc.drawRectangle(x0, y0, width, height);
}

function min(a as Numeric, b as Numeric) {
  return a < b ? a : b;
}

(:glance)
public function getDangerLevelToday(
  forecast as SimpleAvalancheForecast
) as Number {
  var now = Time.now();
  for (var i = 0; i < forecast.size(); i++) {
    var warning = forecast[i];
    var validity = warning["validity"] as Array;
    if (now.compare(validity[0]) > 0 && now.compare(validity[1]) <= 0) {
      return warning["dangerLevel"];
    }
  }

  return 0;
}

(:glance)
public function newBufferedBitmap(
  options as
    {
      :width as Number,
      :height as Number,
      :palette as Array<Graphics.ColorType>,
      :colorDepth as Number,
      :bitmapResource as Ui.BitmapResource,
      :alphaBlending as Graphics.AlphaBlending,
    }
) {
  if (Graphics has :createBufferedBitmap) {
    return Graphics.createBufferedBitmap(options).get();
  }

  return new Graphics.BufferedBitmap(options);
}

(:glance)
public function useBufferedBitmaps() {
  var deviceSettings = System.getDeviceSettings();
  var partNumber = deviceSettings.partNumber;
  // Low mem for F6
  if (
    partNumber.equals("006-B3290-00") ||
    partNumber.equals("006-B3289-00") ||
    partNumber.equals("006-B3287-00")
  ) {
    return false;
  }

  return true;
}
