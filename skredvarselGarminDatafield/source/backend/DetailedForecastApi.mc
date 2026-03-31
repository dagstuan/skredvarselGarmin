import Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Time;

// Returns [response, storedTime] array
(:background)
function getDetailedWarningsForLocation() as Array? {
  return Storage.getValue("location_detailed_forecast");
}

(:background)
function loadDetailedWarningsForLocation(
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  var location = $.getLocation();

  if (location == null) {
    if ($.Debug) {
      $.log("No location available. Not loading detailed warnings.");
    }
    return;
  }

  if ($.Debug) {
    $.log("Loading detailed forecast for location.");
  }

  var language = $.getForecastLanguage();
  var now = Time.now();
  var start = $.getFormattedDateForApiCall(now);
  var end = $.getFormattedDateForApiCall(now);

  var path =
    "/detailedWarningsByLocation/" +
    location[0] +
    "/" +
    location[1] +
    "/" +
    language +
    "/" +
    start +
    "/" +
    end;

  $.makeApiRequest(path, "location_detailed_forecast", callback, useQueue);
}
