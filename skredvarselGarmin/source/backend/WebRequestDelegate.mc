import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;

const BaseApiUrl = "https://skredvarsel.app/api";

(:background)
class WebRequestDelegate {
  private var _queue;
  private var _path as String;
  private var _storageKey as String?;
  private var _callback as (Method(data) as Void);

  // Set up the callback to the view
  function initialize(
    queue as CommandExecutor,
    path as String,
    storageKey as String?,
    callback as (Method(data) as Void)
  ) {
    _queue = queue;
    _path = path;
    _storageKey = storageKey;
    _callback = callback;
  }

  function makeRequest() {
    _queue.addCommand(
      new WebRequestCommand(
        $.BaseApiUrl + _path,
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
      if (_storageKey != null) {
        $.logMessage("Storing in storage with key: " + _storageKey);
        Storage.setValue(_storageKey, data);
      }
    } else {
      $.logMessage("Failed request. Response code: " + responseCode);
    }

    _callback.invoke(data);
  }
}
