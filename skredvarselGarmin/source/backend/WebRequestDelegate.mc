import Toybox.Lang;

using Toybox.Communications;
using Toybox.Time;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;
using Toybox.System;

// const FrontendBaseUrl = "http://localhost:5173";
// const ApiBaseUrl = "https://localhost:8080/api";
const FrontendBaseUrl = "https://skredvarsel.app";
const ApiBaseUrl = "https://skredvarsel.app/api";

typedef WebRequestCallbackData as Null or Dictionary or String;
typedef WebRequestCallback as (Method
  (responseCode as Number, data as WebRequestCallbackData) as Void
);

typedef WebRequestDelegateCallbackData as WebRequestCallbackData or Array;
typedef WebRequestDelegateCallback as (Method
  (responseCode as Number, data as WebRequestDelegateCallbackData) as Void
);

(:background)
function makeGetRequestWithAuthorization(
  url as String,
  callback as WebRequestCallback
) {
  var deviceSettings = System.getDeviceSettings();

  Communications.makeWebRequest(
    url,
    null,
    {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Garmin " + deviceSettings.uniqueIdentifier,
      },
    },
    callback
  );
}

(:background)
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
      $.log(Lang.format("Fetching: $1$", [_path]));
    }

    $.makeGetRequestWithAuthorization($.ApiBaseUrl + _path, method(:onReceive));
  }

  function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      if ($.Debug) {
        $.log(
          Lang.format("200 OK. Storing in storage with key: $1$", [_storageKey])
        );
      }

      Storage.setValue(_storageKey, [data, Time.now().value()]);
    } else if (responseCode == 401) {
      if ($.Debug) {
        $.log("Api responded with 401. No subscription for user.");
      }

      $.setHasSubscription(false);
    } else if ($.Debug) {
      $.log(Lang.format("Failed request. Response code: $1$", [responseCode]));
    }

    _callback.invoke(responseCode, data as WebRequestDelegateCallbackData);
  }
}
