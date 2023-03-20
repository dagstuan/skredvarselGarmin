import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;

const BaseApiUrl = "https://skredvarsel.app/api";
// const BaseApiUrl = "https://localhost:8080/api";

typedef WebRequestCallbackData as Null or Dictionary or String;

typedef WebRequestDelegateCallback as (Method
  (responseCode as Number, data as WebRequestCallbackData) as Void
);

(:glance)
function makeApiRequest(
  path as String,
  storageKey as String,
  callback as WebRequestDelegateCallback,
  useQueue as Boolean
) {
  if (useQueue) {
    if ($.commandQueue == null) {
      $.commandQueue = new CommandExecutor();
    }
    $.commandQueue.addCommand(path, storageKey, callback);
  } else {
    var delegate = new WebRequestDelegate(path, storageKey, callback);
    delegate.makeRequest();
  }
}

(:background)
class WebRequestDelegate {
  private var _path as String;
  private var _storageKey as String;
  private var _callback as WebRequestDelegateCallback?;

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
    if ($.Debug) {
      $.logMessage("Fetching: " + _path);
    }

    Communications.makeWebRequest(
      $.BaseApiUrl + _path,
      null,
      {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "Authorization" => "Garmin " + $.getDeviceIdentifier(),
        },
      },
      method(:onReceive)
    );
  }

  function onReceive(
    responseCode as Number,
    data as Dictionary<String, Object?> or String or Null
  ) as Void {
    if (responseCode == 200) {
      if (_storageKey != null) {
        if ($.Debug) {
          $.logMessage("200 OK. Storing in storage with key: " + _storageKey);
        }
        Storage.setValue(_storageKey, [data, Time.now().value()]);
      }
    } else if (responseCode == 401) {
      if ($.Debug) {
        $.logMessage("Api responded with 401. No subscription for user.");
      }
      $.setHasSubscription(false);
    } else {
      if ($.Debug) {
        $.logMessage("Failed request. Response code: " + responseCode);
      }
    }

    _callback.invoke(responseCode, data);
  }
}
