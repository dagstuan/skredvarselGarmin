using Toybox.Activity;
using Toybox.Weather;
using Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Application.Properties;
using Toybox.Time;

const LastLocationStorageKey = "last_location";
const LastLocationTimeStorageKey = "last_location_time";

(:glance,:background)
var useLocation as Lang.Boolean?;

(:glance,:background)
function getUseLocation() as Lang.Boolean {
  if ($.useLocation == null) {
    $.useLocation = Properties.getValue("useLocation") as Lang.Boolean;
  }

  return $.useLocation;
}

(:glance,:background)
function getLocation() as [ Lang.Double, Lang.Double ]? {
  // Get Location from Garmin Weather
  if (Toybox has :Weather && false) {
    var w = Weather.getCurrentConditions();
    if (w != null && w.observationLocationPosition != null) {
      $.log("Location obtained from Weather");
      var loc = w.observationLocationPosition.toDegrees();
      saveLocation(loc);
      return loc;
    }
  }

  // Get Location from Activity
  var lastActivity = Activity.getActivityInfo();
  if (lastActivity != null) {
    var lastLocationTime = $.getLastLocationTime();

    if (lastActivity.startTime != null && lastActivity.startTime.compare(new Time.Moment(lastLocationTime)) > 0) {
      $.log("Location obtained from Activity");
      var loc = lastActivity.currentLocation.toDegrees();
      saveLocation(loc);
      return loc;
    }
  }

  $.log("Location obtained from Storage.");
  // Get last known Location
  return Storage.getValue(LastLocationStorageKey) as [ Lang.Double, Lang.Double ];
}

(:glance,:background)
function getLastLocationTime() as Lang.Number {
  var value = Storage.getValue(LastLocationTimeStorageKey) as Lang.Number?;

  return value != null ? value : 0;
}

(:glance,:background)
function saveLocation(loc as [ Lang.Double, Lang.Double ]) {
  try {
    Storage.setValue(LastLocationStorageKey, loc);
    Storage.setValue(LastLocationTimeStorageKey, Time.now().value());
  } catch (ex) {}
}
