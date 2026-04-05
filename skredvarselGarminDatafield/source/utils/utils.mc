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

// AvalancheProblemType IDs matching the backend enum
const PROBLEM_TYPE_NOT_GIVEN = 0;
const PROBLEM_TYPE_NEW_SNOW_LOOSE = 3;
const PROBLEM_TYPE_WET_SNOW_LOOSE = 5;
const PROBLEM_TYPE_NEW_SNOW_SLAB = 7;
const PROBLEM_TYPE_WIND_DRIFTED_SNOW = 10;
const PROBLEM_TYPE_PERSISTENT_WEAK_LAYER = 30;
const PROBLEM_TYPE_WET_SNOW_SLAB = 45;
const PROBLEM_TYPE_GLIDING_SNOW = 50;

function getProblemTypeName(typeId as Number) as String {
  if (typeId == PROBLEM_TYPE_NEW_SNOW_LOOSE) {
    return $.getOrLoadResourceString(
      "Nysnø (løssnøskred)",
      :ProblemTypeNewSnowLoose
    );
  } else if (typeId == PROBLEM_TYPE_WET_SNOW_LOOSE) {
    return $.getOrLoadResourceString(
      "Våt snø (løssnøskred)",
      :ProblemTypeWetSnowLoose
    );
  } else if (typeId == PROBLEM_TYPE_NEW_SNOW_SLAB) {
    return $.getOrLoadResourceString(
      "Nysnø (flakskred)",
      :ProblemTypeNewSnowSlab
    );
  } else if (typeId == PROBLEM_TYPE_WIND_DRIFTED_SNOW) {
    return $.getOrLoadResourceString(
      "Fokksnø (flakskred)",
      :ProblemTypeWindDriftedSnow
    );
  } else if (typeId == PROBLEM_TYPE_PERSISTENT_WEAK_LAYER) {
    return $.getOrLoadResourceString(
      "Vedv. svakt lag (flakskred)",
      :ProblemTypePersistentWeakLayer
    );
  } else if (typeId == PROBLEM_TYPE_WET_SNOW_SLAB) {
    return $.getOrLoadResourceString(
      "Våt snø (flakskred)",
      :ProblemTypeWetSnowSlab
    );
  } else if (typeId == PROBLEM_TYPE_GLIDING_SNOW) {
    return $.getOrLoadResourceString("Glideskred", :ProblemTypeGlidingSnow);
  }

  return $.getOrLoadResourceString("Ikke gitt", :NotGiven);
}

function getIconResourceForProblemType(typeId as Number) {
  if (
    typeId == PROBLEM_TYPE_NEW_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_NEW_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemNewSnow;
  } else if (
    typeId == PROBLEM_TYPE_WET_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_WET_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemWetSnow;
  } else if (typeId == PROBLEM_TYPE_WIND_DRIFTED_SNOW) {
    return $.Rez.Drawables.ProblemWindSlab;
  } else if (typeId == PROBLEM_TYPE_PERSISTENT_WEAK_LAYER) {
    return $.Rez.Drawables.ProblemPersistentWeakLayer;
  } else if (typeId == PROBLEM_TYPE_GLIDING_SNOW) {
    return $.Rez.Drawables.ProblemGlidingSnow;
  }
  return $.Rez.Drawables.AvalancheIconSvg;
}

function getIconResourceForProblemTypeLarge(typeId as Number) {
  if (
    typeId == PROBLEM_TYPE_NEW_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_NEW_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemNewSnowLarge;
  } else if (
    typeId == PROBLEM_TYPE_WET_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_WET_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemWetSnowLarge;
  } else if (typeId == PROBLEM_TYPE_WIND_DRIFTED_SNOW) {
    return $.Rez.Drawables.ProblemWindSlabLarge;
  } else if (typeId == PROBLEM_TYPE_PERSISTENT_WEAK_LAYER) {
    return $.Rez.Drawables.ProblemPersistentWeakLayerLarge;
  } else if (typeId == PROBLEM_TYPE_GLIDING_SNOW) {
    return $.Rez.Drawables.ProblemGlidingSnowLarge;
  }
  return $.Rez.Drawables.AvalancheIconSvg;
}

function getIconResourceForProblemTypeGray(typeId as Number) {
  if (
    typeId == PROBLEM_TYPE_NEW_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_NEW_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemNewSnowGray;
  } else if (
    typeId == PROBLEM_TYPE_WET_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_WET_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemWetSnowGray;
  } else if (typeId == PROBLEM_TYPE_WIND_DRIFTED_SNOW) {
    return $.Rez.Drawables.ProblemWindSlabGray;
  } else if (typeId == PROBLEM_TYPE_PERSISTENT_WEAK_LAYER) {
    return $.Rez.Drawables.ProblemPersistentWeakLayerGray;
  } else if (typeId == PROBLEM_TYPE_GLIDING_SNOW) {
    return $.Rez.Drawables.ProblemGlidingSnowGray;
  }
  return $.Rez.Drawables.AvalancheIconSvg;
}

function getIconResourceForProblemTypeLargeGray(typeId as Number) {
  if (
    typeId == PROBLEM_TYPE_NEW_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_NEW_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemNewSnowLargeGray;
  } else if (
    typeId == PROBLEM_TYPE_WET_SNOW_LOOSE ||
    typeId == PROBLEM_TYPE_WET_SNOW_SLAB
  ) {
    return $.Rez.Drawables.ProblemWetSnowLargeGray;
  } else if (typeId == PROBLEM_TYPE_WIND_DRIFTED_SNOW) {
    return $.Rez.Drawables.ProblemWindSlabLargeGray;
  } else if (typeId == PROBLEM_TYPE_PERSISTENT_WEAK_LAYER) {
    return $.Rez.Drawables.ProblemPersistentWeakLayerLargeGray;
  } else if (typeId == PROBLEM_TYPE_GLIDING_SNOW) {
    return $.Rez.Drawables.ProblemGlidingSnowLargeGray;
  }
  return $.Rez.Drawables.AvalancheIconSvg;
}

const DrawOutlines = false;

const TIME_TO_CONSIDER_DATA_STALE = Gregorian.SECONDS_PER_HOUR / 2;

(:background)
function isSwedishRegion(regionId as String) as Boolean {
  return regionId.substring(0, 3).equals("se_");
}

function getRegionName(regionId as String or Number) as String {
  if (regionId instanceof Lang.String) {
    if ($.isSwedishRegion(regionId as String)) {
      return $.getSwedishRegionName(regionId as String);
    }
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

  return connectionInfo[:bluetooth][:state].equals(
    System.CONNECTION_STATE_CONNECTED
  );
}

function getDeviceScreenWidth() as Number {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.screenWidth;
}

function getDeviceScreenHeight() as Number {
  var deviceSettings = System.getDeviceSettings();
  return deviceSettings.screenHeight;
}

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

function lowercaseFirstChar(str as String) as String {
  if (str.length() == 0) {
    return str;
  }

  var firstChar = str.substring(0, 1).toLower();
  var rest = str.substring(1, str.length());

  return firstChar + rest;
}

(:release)
public function log(message as String) {}

(:debug,:background)
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

// Converts [aboveTreeline, atTreeline, belowTreeline] booleans to an exposedHeightFill value.
// Uses the 3-piece triplet icon; each zone maps to top/mid/bottom triplet independently.
// 3=above+below, 4=treeline only, 5=above only, 6=below only,
// 7=above+treeline, 8=treeline+below, 9=all three
function exposedHeightZonesToFill(zones as Array<Boolean>) as Number {
  var above = zones[0];
  var atLine = zones[1];
  var below = zones[2];

  if (above && !atLine && !below) {
    return 5;
  }
  if (!above && !atLine && below) {
    return 6;
  }
  if (!above && atLine && !below) {
    return 4;
  }
  if (above && atLine && !below) {
    return 7;
  }
  if (!above && atLine && below) {
    return 8;
  }
  if (above && !atLine && below) {
    return 3;
  }
  if (above && atLine && below) {
    return 9;
  }
  return 0;
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

public function getDisplayDateForWarning(
  warning as DetailedAvalancheWarning
) as Time.Moment {
  return $.parseDate((warning["validity"] as Array)[1]).subtract(
    new Time.Duration(1)
  );
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
