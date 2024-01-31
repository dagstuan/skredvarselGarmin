import Toybox.Lang;

using Toybox.Communications;
using Toybox.Time;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

//const FrontendBaseUrl = "http://localhost:5173";
//const ApiBaseUrl = "https://localhost:8080/api";
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
    $.log(Lang.format("Fetching: $1$", [_path]));

    Communications.makeWebRequest(
      $.ApiBaseUrl + _path,
      null,
      {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "Authorization" => Lang.format("Garmin $1$", [
            $.getDeviceIdentifier(),
          ]),
        },
      },
      method(:onReceive)
    );
  }

  function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      $.log(
        Lang.format("200 OK. Storing in storage with key: $1$", [_storageKey])
      );

      Storage.setValue(_storageKey, [data, Time.now().value()]);
    } else if (responseCode == 401) {
      $.log("Api responded with 401. No subscription for user.");

      $.setHasSubscription(false);

      try {
        Ui.switchToView(
          new SetupSubscriptionView(),
          new SetupSubscriptionViewDelegate(),
          Ui.SLIDE_BLINK
        );
      } catch (ex) {
        $.log(
          "Failed to switch to setupSubscriptionView after API returned 401."
        );
      }

      // Make sure we dont invoke the callback if API returned 401.
      return;
    } else {
      $.log(Lang.format("Failed request. Response code: $1$", [responseCode]));
    }

    _callback.invoke(responseCode, data as WebRequestDelegateCallbackData);
  }
}
