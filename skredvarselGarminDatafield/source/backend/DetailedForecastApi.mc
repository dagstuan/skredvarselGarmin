import Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Time;

// Returns [response, storedTime] array
(:background)
function getDetailedWarningsForLocation() as Array? {
  return Storage.getValue("location_detailed_forecast") as Array?;
}

(:background)
function loadDetailedWarningsForLocation(
  location as [Lang.Double, Lang.Double],
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
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

  var responseHandler = new DetailedWarningsResponseHandler(location, callback);
  $.makeApiRequest(
    path,
    "location_detailed_forecast",
    responseHandler.getCallback(),
    useQueue
  );
}

(:background)
class DetailedWarningsResponseHandler {
  private var _location as [Lang.Double, Lang.Double];
  private var _callback as WebRequestDelegateCallback?;

  function initialize(
    location as [Lang.Double, Lang.Double],
    callback as WebRequestDelegateCallback
  ) {
    _location = location;
    _callback = callback;
  }

  function getCallback() as WebRequestDelegateCallback {
    return method(:onReceive);
  }

  function onReceive(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    if (responseCode == 200) {
      if ($.Debug) {
        $.log("Detailed forecast loaded successfully. Saving location.");
      }
      $.saveLocation(_location);
    }

    _callback.invoke(responseCode, data);
  }
}
