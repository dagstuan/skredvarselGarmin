using Toybox.Activity;
using Toybox.Position;
using Toybox.Weather;
using Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Math;
using Toybox.Time;

(:background)
function getLocation() as [Lang.Double, Lang.Double]? {
  var activityInfo = Activity.getActivityInfo();
  if (activityInfo != null && activityInfo.currentLocation != null) {
    if ($.Debug) {
      $.log("Location obtained from Activity");
    }

    return activityInfo.currentLocation.toDegrees();
  }

  var weatherLocation = getWeatherLocation();
  if (weatherLocation != null) {
    return weatherLocation;
  }

  var storedLocation = getStoredLocation();
  if (storedLocation != null) {
    if ($.Debug) {
      $.log("Location obtained from storage.");
    }

    return storedLocation;
  }

  if ($.Debug) {
    $.log("Location unavailable.");
  }

  return null;
}

function getCurrentElevation() as Lang.Float? {
  try {
    var positionInfo = Position.getInfo();
    if (positionInfo.altitude != null) {
      var altitude = positionInfo.altitude as Lang.Float;
      return altitude >= 0.0f ? altitude : 0.0f;
    }
  } catch (ex) {
    if ($.Debug) {
      $.log("Failed getting GPS elevation: " + ex);
    }
  }

  var activityInfo = Activity.getActivityInfo();
  if (activityInfo != null && activityInfo.altitude != null) {
    var altitude = activityInfo.altitude as Lang.Float;
    if ($.Debug) {
      $.log("GPS elevation unavailable. Falling back to activity altitude.");
    }

    return altitude >= 0.0f ? altitude : 0.0f;
  }

  return null;
}

(:background)
function getWeatherLocation() as [Lang.Double, Lang.Double]? {
  if (!(Toybox has :Weather)) {
    return null;
  }

  try {
    var weather = Weather.getCurrentConditions();
    if (weather != null && weather.observationLocationPosition != null) {
      if ($.Debug) {
        $.log("Location obtained from Weather");
      }

      return weather.observationLocationPosition.toDegrees();
    }
  } catch (ex) {
    if ($.Debug) {
      $.log("Failed getting location from Weather: " + ex);
    }
  }

  return null;
}

(:background)
function getStoredLocation() as [Lang.Double, Lang.Double]? {
  return Storage.getValue("last_location") as [Lang.Double, Lang.Double];
}

(:background)
function getLastLocationTime() as Lang.Number {
  var value = Storage.getValue("last_location_time") as Lang.Number?;

  return value != null ? value : 0;
}

(:background)
function saveLocation(loc as [Lang.Double, Lang.Double]) {
  try {
    Storage.setValue("last_location", loc);
    Storage.setValue("last_location_time", Time.now().value());
  } catch (ex) {}
}

function getDistanceInKilometers(
  fromLocation as [Lang.Double, Lang.Double],
  toLocation as [Lang.Double, Lang.Double]
) as Lang.Double {
  var earthRadiusKm = 6371.0f;
  var fromLat = Math.toRadians(fromLocation[0]);
  var toLat = Math.toRadians(toLocation[0]);
  var deltaLat = toLat - fromLat;
  var deltaLon = Math.toRadians(toLocation[1] - fromLocation[1]);

  var sinLat = Math.sin(deltaLat / 2.0f);
  var sinLon = Math.sin(deltaLon / 2.0f);
  var haversine =
    sinLat * sinLat + Math.cos(fromLat) * Math.cos(toLat) * sinLon * sinLon;

  if (haversine < 0.0f) {
    haversine = 0.0f;
  } else if (haversine > 1.0f) {
    haversine = 1.0f;
  }

  var arc =
    2.0f * Math.atan2(Math.sqrt(haversine), Math.sqrt(1.0f - haversine));
  return earthRadiusKm * arc;
}
