using Toybox.Activity;
using Toybox.Weather;
using Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Application.Properties;

const LastLocationStorageKey = "last_location";

(:glance,:background)
var useLocation as Lang.Boolean?;

(:glance,:background)
function getUseLocation() as Lang.Boolean {
  if ($.useLocation == null) {
    $.useLocation = Properties.getValue("useLocation") as Lang.Boolean;
  }

  return $.useLocation;
}

(:background)
function getLocation() as Lang.Array<Lang.Double>? {
  // Get Location from Garmin Weather
  if (Toybox has :Weather) {
    var w = Weather.getCurrentConditions();
    if (w != null && w.observationLocationPosition != null) {
      $.log("Location obtained from Weather");
      var loc = w.observationLocationPosition.toDegrees();
      saveLocation(loc);
      return loc;
    }
  }

  // Get Location from Activity
  var activityLoc = Activity.getActivityInfo().currentLocation;
  if (activityLoc != null) {
    $.log("Location obtained from Activity");
    var loc = activityLoc.toDegrees();
    saveLocation(loc);
    return loc;
  }

  $.log("Location obtained from Storage.");
  // Get last known Location
  return Storage.getValue(LastLocationStorageKey);
}

(:background)
function saveLocation(loc as Lang.Array<Lang.Double>) {
  try {
    Storage.setValue(LastLocationStorageKey, loc);
  } catch (ex) {}
}
