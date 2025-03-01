using Toybox.Activity;
using Toybox.Weather;
using Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Application.Properties;
using Toybox.Time;

(:background)
var useLocation as Lang.Boolean?;

(:background)
function getUseLocation() as Lang.Boolean {
  if ($.useLocation == null) {
    $.useLocation = Properties.getValue("useLocation") as Lang.Boolean;
  }

  return $.useLocation;
}

(:background)
function getLocation() as [ Lang.Double, Lang.Double ]? {
  // Get Location from Garmin Weather
  if (Toybox has :Weather) {
    try {
      var w = Weather.getCurrentConditions();
      if (w != null && w.observationLocationPosition != null) {
        if ($.Debug) {
          $.log("Location obtained from Weather");
        }

        var loc = w.observationLocationPosition.toDegrees();
        saveLocation(loc);
        return loc;
      }
    } catch (ex) {
      if ($.Debug) {
        $.log("Failed getting location from Weather: " + ex);
      }
    }
  }

  // Get Location from Activity
  var lastActivity = Activity.getActivityInfo();
  if (lastActivity != null) {
    var lastLocationTime = $.getLastLocationTime();

    if (
      lastActivity.currentLocation != null &&
      lastActivity.startTime != null &&
      lastActivity.startTime.compare(new Time.Moment(lastLocationTime)) > 0
    ) {
      if ($.Debug) {
        $.log("Location obtained from Activity");
      }

      var loc = lastActivity.currentLocation.toDegrees();
      saveLocation(loc);
      return loc;
    }
  }

  if ($.Debug) {
    $.log("Location obtained from Storage.");
  }
  // Get last known Location
  return Storage.getValue("last_location") as [ Lang.Double, Lang.Double ];
}

(:background)
function getLastLocationTime() as Lang.Number {
  var value = Storage.getValue("last_location_time") as Lang.Number?;

  return value != null ? value : 0;
}

(:background)
function saveLocation(loc as [ Lang.Double, Lang.Double ]) {
  try {
    Storage.setValue("last_location", loc);
    Storage.setValue("last_location_time", Time.now().value());
  } catch (ex) {}
}
