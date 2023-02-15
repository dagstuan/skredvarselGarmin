import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;

const BaseApiUrl = "https://skredvarsel-garmin-api.fly.dev";

(:background)
class GetAvalancheForecastRequestDelegate {
  hidden var _skredvarselStorage as SkredvarselStorage;

  hidden var _callback;
  hidden var _regionId;

  hidden var _queue;

  // Set up the callback to the view
  function initialize(
    skredvarselStorage as SkredvarselStorage,
    queue as CommandExecutor,
    regionId as String,
    callback as (Method() as Void)
  ) {
    _queue = queue;
    _callback = callback;
    _regionId = regionId;
    _skredvarselStorage = skredvarselStorage;
  }

  function makeRequest() {
    var now = Time.now();
    var twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);
    var start = now.subtract(twoDays);
    var end = now.add(twoDays);

    var path =
      "/avalancheWarningByRegion/" +
      _regionId +
      "/1/" +
      getFormattedDate(start) +
      "/" +
      getFormattedDate(end);

    Sys.println("Loading warning for region " + _regionId);

    _queue.addCommand(
      new WebRequestCommand(
        $.BaseApiUrl + path,
        null,
        {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        },
        method(:onReceive)
      )
    );
  }

  // Receive the data from the web request
  function onReceive(
    responseCode as Number,
    data as Dictionary<String, Object?> or String or Null
  ) as Void {
    if (responseCode == 200) {
      Sys.println("Request Successful for region: " + _regionId); // print success

      _skredvarselStorage.setForecastDataForRegion(_regionId, data);
    } else {
      Sys.println("Response: " + responseCode); // print response code
    }

    _callback.invoke();
  }
}
