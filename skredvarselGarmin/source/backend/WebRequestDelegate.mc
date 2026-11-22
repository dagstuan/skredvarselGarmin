import Toybox.Lang;

using Toybox.Communications;
using Toybox.Time;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;
using Toybox.System;

// const FrontendBaseUrl = "https://localhost:5173";
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

  // For detailed forecasts, stores the texts per day under their own keys.
  // The texts are removed from data, and data without them is returned, to be
  // stored as the forecast. Storing it all as one value needs more memory than
  // the background process has. See DetailedWarningTexts.mc.
  //
  // Returns the same object, not a copy, since a copy would need memory for
  // the forecast twice.
  (:noLimitedBackgroundMemory)
  private function storeTexts(
    data as WebRequestCallbackData
  ) as WebRequestCallbackData {
    if (data instanceof Array && $.isDetailedWarningsCacheKey(_storageKey)) {
      // Passed on directly, so the texts are freed before the forecast is
      // stored.
      $.storeDetailedWarningTexts(
        _storageKey,
        $.removeDetailedWarningTexts(data as Array)
      );
    }
    return data;
  }

  // Limited devices don't fetch the texts.
  (:limitedBackgroundMemory)
  private function storeTexts(
    data as WebRequestCallbackData
  ) as WebRequestCallbackData {
    return data;
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

      Storage.deleteValue(_storageKey);
      var dataWithoutTexts = storeTexts(data);
      Storage.setValue(_storageKey, [dataWithoutTexts, Time.now().value()]);
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
