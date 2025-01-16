import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Math;

(:debug)
const Debug = true;
(:release)
const Debug = false;

const DrawOutlines = false;

(:glance)
const TIME_TO_SHOW_LOADING = Gregorian.SECONDS_PER_DAY;

const TIME_TO_CONSIDER_DATA_STALE = Gregorian.SECONDS_PER_HOUR / 2;

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
function getRegionName(regionId as String or Number) as String {
  if (regionId instanceof Lang.String) {
    regionId = regionId.toNumber();
  }

  if (regionId == 3003) {
    return "Nordenskiöld Land";
  } else if (regionId == 3006) {
    return "Finnmarkskysten";
  } else if (regionId == 3007) {
    return "Vest-Finnmark";
  } else if (regionId == 3009) {
    return "Nord-Troms";
  } else if (regionId == 3010) {
    return "Lyngen";
  } else if (regionId == 3011) {
    return "Tromsø";
  } else if (regionId == 3012) {
    return "Sør-Troms";
  } else if (regionId == 3013) {
    return "Indre Troms";
  } else if (regionId == 3014) {
    return "Lofoten og Vesterålen";
  } else if (regionId == 3015) {
    return "Ofoten";
  } else if (regionId == 3016) {
    return "Salten";
  } else if (regionId == 3017) {
    return "Svartisen";
  } else if (regionId == 3018) {
    return "Helgeland";
  } else if (regionId == 3022) {
    return "Trollheimen";
  } else if (regionId == 3023) {
    return "Romsdal";
  } else if (regionId == 3024) {
    return "Sunnmøre";
  } else if (regionId == 3027) {
    return "Indre Fjordane";
  } else if (regionId == 3028) {
    return "Jotunheimen";
  } else if (regionId == 3029) {
    return "Indre Sogn";
  } else if (regionId == 3031) {
    return "Voss";
  } else if (regionId == 3032) {
    return "Hallingdal";
  } else if (regionId == 3034) {
    return "Hardanger";
  } else if (regionId == 3035) {
    return "Vest-Telemark";
  } else if (regionId == 3037) {
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
function getDeviceIdentifier() as String {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.uniqueIdentifier;
}

(:glance)
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

(:glance)
function arrayContainsString(arr as Array<String>, str as String) {
  for (var i = 0; i < arr.size(); i++) {
    if (arr[i].equals(str)) {
      return true;
    }
  }

  return false;
}

function removeStringFromArray(currArray as Array<String>, value as String) {
  var newArray = [];
  for (var i = 0; i < currArray.size(); i++) {
    var elem = currArray[i];
    if (!elem.equals(value)) {
      newArray.add(elem);
    }
  }

  return newArray;
}

public function minValue(arr as Array<Number>) {
  var size = arr.size();
  if (size == 0) {
    throw new SkredvarselGarminException("Empty array sent to minValue");
  }

  var min = 2147483647;
  for (var i = 0; i < size; i++) {
    var val = arr[i];
    if (val < min) {
      min = val;
    }
  }
  return min;
}

(:release)
public function log(message as String) {}

(:background,:debug)
public function log(message as String) {
  var info = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);

  System.println(
    Lang.format("$1$:$2$:$3$ $4$ $5$ $6$ $7$ - $8$", [
      info.hour.format("%02u"),
      info.min.format("%02u"),
      info.sec.format("%02u"),
      info.day_of_week,
      info.day,
      info.month,
      info.year,
      message,
    ])
  );
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

(:release)
function drawOutline(
  dc as Graphics.Dc,
  x0 as Numeric,
  y0 as Numeric,
  width as Numeric,
  height as Numeric
) {}

(:debug)
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

function max(arr as Array<Numeric>) {
  var max = arr[0];
  for (var i = 0; i < arr.size(); i++) {
    if (arr[i] > max) {
      max = arr[i];
    }
  }

  return max;
}

(:background)
public function getDangerLevelToday(
  forecast as SimpleAvalancheForecast
) as Number {
  var today = Time.today();
  for (var i = 0; i < forecast.size(); i++) {
    var warning = forecast[i];
    var validity = warning["validity"] as Array;
    if (
      today.compare($.parseDate(validity[0])) >= 0 &&
      today.compare($.parseDate(validity[1])) < 0
    ) {
      return warning["dangerLevel"];
    }
  }

  return 0;
}

public function getStartDateForDetailedWarnings() {
  var startDate = Time.today();
  var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
  if (now.hour >= 17) {
    startDate = addDays(startDate, 1);
  }
  return startDate;
}

public function getDateIndexForDetailedWarnings(
  warnings as Array<DetailedAvalancheWarning>,
  date as Time.Moment
) {
  for (var i = 0; i < warnings.size(); i++) {
    var validity = warnings[i]["validity"] as Array;
    if (
      date.compare($.parseDate(validity[0])) >= 0 &&
      date.compare($.parseDate(validity[1])) < 0
    ) {
      return i;
    }
  }

  return -1;
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
  return Graphics has :createBufferedBitmap
    ? Graphics.createBufferedBitmap(options).get()
    : new Graphics.BufferedBitmap(options);
}

(:glance)
public function getStorageDataAge(data as Array) {
  return Time.now().compare(new Time.Moment(data[1]));
}
