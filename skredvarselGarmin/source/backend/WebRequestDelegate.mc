import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;

const BaseApiUrl = "https://skredvarsel.app/api";

typedef WebRequestCallbackData as Null or Dictionary or String;

typedef WebRequestDelegateCallback as (Method
  (responseCode as Number, data as WebRequestCallbackData) as Void
);

(:background)
class WebRequestDelegate {
  private var _path as String;
  private var _storageKey as String;
  private var _callback as WebRequestDelegateCallback?;

  // Set up the callback to the view
  function initialize(
    path as String,
    storageKey as String?,
    callback as WebRequestDelegateCallback
  ) {
    _path = path;
    _storageKey = storageKey;
    _callback = callback;
  }

  function makeRequest() {
    $.logMessage("Fetching: " + _path);
    Communications.makeWebRequest(
      $.BaseApiUrl + _path,
      null,
      {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      },
      method(:onReceive)
    );
  }

  // Receive the data from the web request
  function onReceive(
    responseCode as Number,
    data as Dictionary<String, Object?> or String or Null
  ) as Void {
    if (responseCode == 200) {
      if (_storageKey != null) {
        $.logMessage("200 OK. Storing in storage with key: " + _storageKey);
        Storage.setValue(_storageKey, [data, Time.now().value()]);
      }
    } else {
      $.logMessage("Failed request. Response code: " + responseCode);
    }

    _callback.invoke(responseCode, data);
  }
}
