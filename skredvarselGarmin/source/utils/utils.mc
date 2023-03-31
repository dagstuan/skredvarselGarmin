import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Math;

const Debug = false;
const DrawOutlines = false;

(:glance)
const TIME_TO_SHOW_LOADING = Gregorian.SECONDS_PER_DAY;

const TIME_TO_CONSIDER_DATA_STALE = Gregorian.SECONDS_PER_HOUR * 0.5;

function getSortedRegionIds() as Array<String> {
  return [
    "3003",
    "3006",
    "3007",
    "3009",
    "3010",
    "3011",
    "3012",
    "3013",
    "3014",
    "3015",
    "3016",
    "3017",
    "3018",
    "3022",
    "3023",
    "3024",
    "3027",
    "3028",
    "3029",
    "3031",
    "3032",
    "3034",
    "3035",
    "3037",
  ];
}

(:glance)
function getRegionName(regionId as String) as String {
  if (regionId.equals("3003")) {
    return "Nordenskiöld Land";
  } else if (regionId.equals("3006")) {
    return "Finnmarkskysten";
  } else if (regionId.equals("3007")) {
    return "Vest-Finnmark";
  } else if (regionId.equals("3009")) {
    return "Nord-Troms";
  } else if (regionId.equals("3010")) {
    return "Lyngen";
  } else if (regionId.equals("3011")) {
    return "Tromsø";
  } else if (regionId.equals("3012")) {
    return "Sør-Troms";
  } else if (regionId.equals("3013")) {
    return "Indre Troms";
  } else if (regionId.equals("3014")) {
    return "Lofoten og Vesterålen";
  } else if (regionId.equals("3015")) {
    return "Ofoten";
  } else if (regionId.equals("3016")) {
    return "Salten";
  } else if (regionId.equals("3017")) {
    return "Svartisen";
  } else if (regionId.equals("3018")) {
    return "Helgeland";
  } else if (regionId.equals("3022")) {
    return "Trollheimen";
  } else if (regionId.equals("3023")) {
    return "Romsdal";
  } else if (regionId.equals("3024")) {
    return "Sunnmøre";
  } else if (regionId.equals("3027")) {
    return "Indre Fjordane";
  } else if (regionId.equals("3028")) {
    return "Jotunheimen";
  } else if (regionId.equals("3029")) {
    return "Indre Sogn";
  } else if (regionId.equals("3031")) {
    return "Voss";
  } else if (regionId.equals("3032")) {
    return "Hallingdal";
  } else if (regionId.equals("3034")) {
    return "Hardanger";
  } else if (regionId.equals("3035")) {
    return "Vest-Telemark";
  } else if (regionId.equals("3037")) {
    return "Heiane";
  }

  return "Ukjent region";
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

(:background)
function getDeviceIdentifier() as String {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.uniqueIdentifier;
}

function getDeviceScreenWidth() as Number {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.screenWidth;
}

function getDeviceScreenHeight() as Number {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.screenHeight;
}

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
  }

  return 0xaaaaaa;
}

(:background)
function getFormattedDate(moment as Time.Moment) as String {
  var info = Gregorian.info(moment, Time.FORMAT_SHORT);

  return Lang.format("$1$-$2$-$3$", [
    info.year.format("%04u"),
    info.month.format("%02u"),
    info.day.format("%02u"),
  ]);
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
  return Gregorian.moment({
    :year => dateString.substring(0, 4).toNumber(),
    :month => dateString.substring(5, 7).toNumber(),
    :day => dateString.substring(8, 10).toNumber(),
    :hour => dateString.substring(11, 13).toNumber(),
    :minute => dateString.substring(14, 16).toNumber(),
    :second => dateString.substring(17, 19).toNumber(),
  });
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

function arrayContainsString(arr as Array<String>, str as String) {
  for (var i = 0; i < arr.size(); i++) {
    if (arr[i].equals(str)) {
      return true;
    }
  }

  return false;
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

public function minValue(arr as Array<Number>) {
  if (arr == null || arr.size() == 0) {
    throw new SkredvarselGarminException(
      "Null or empty array sent to minValue"
    );
  }

  var min = 2147483647;
  for (var i = 0; i < arr.size(); i++) {
    var val = arr[i];
    if (val < min) {
      min = val;
    }
  }
  return min;
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

var halfWidthDangerLevelIcon = null;
function getHalfWidthDangerLevelIcon() {
  if ($.halfWidthDangerLevelIcon == null) {
    var level2 = Ui.loadResource($.Rez.Drawables.Level2) as Ui.BitmapResource;
    $.halfWidthDangerLevelIcon = level2.getWidth() / 2;
  }
  return $.halfWidthDangerLevelIcon;
}

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
  dc.setPenWidth(1);
  dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

  dc.drawRectangle(x0, y0, width, height);
}

function min(a as Numeric, b as Numeric) {
  return a < b ? a : b;
}

(:background)
public function getDangerLevelToday(
  forecast as SimpleAvalancheForecast
) as Number {
  var now = Time.now();
  for (var i = 0; i < forecast.size(); i++) {
    var warning = forecast[i];
    var validity = warning["validity"] as Array;
    if (
      now.compare($.parseDate(validity[0])) > 0 &&
      now.compare($.parseDate(validity[1])) <= 0
    ) {
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
public function getStorageDataAge(data as Array) {
  return Time.now().compare(new Time.Moment(data[1]));
}
