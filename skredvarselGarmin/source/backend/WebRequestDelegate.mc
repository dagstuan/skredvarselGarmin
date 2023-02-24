import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;

const BaseApiUrl = "https://skredvarsel.app/api";

typedef WebRequestCallbackData as Dictionary<String, Object?> or String or Null;

typedef WebRequestDelegateCallback as (Method
  (data as WebRequestCallbackData) as Void
);

(:background)
const commandQueue = new CommandExecutor();

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
    $.commandQueue.addCommand($.BaseApiUrl + _path, method(:onReceive));
  }

  // Receive the data from the web request
  function onReceive(
    responseCode as Number,
    data as Dictionary<String, Object?> or String or Null
  ) as Void {
    if (responseCode == 200) {
      if (_storageKey != null) {
        $.logMessage("Storing in storage with key: " + _storageKey);
        Storage.setValue(_storageKey, [data, Time.now().value()]);
      }
    } else {
      $.logMessage("Failed request. Response code: " + responseCode);
    }

    _callback.invoke(data);
  }
}
