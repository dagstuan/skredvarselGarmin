import Toybox.Lang;

using Toybox.Communications;

(:background)
class CommandExecutor {
  private var _head as WebRequestCommand?;
  private var _tail as WebRequestCommand?;

  function initialize() {
    _head = null;
    _tail = null;
  }

  function addCommand(url, callback) {
    var command = new WebRequestCommand(url, callback);

    command._queue = self;

    if (_head == null) {
      _head = command;
      _tail = command;

      command.start();
    } else {
      _tail._next = command;
      _tail = command;
    }
  }

  function finishCommand() {
    // remove the front item in the queue
    var head = _head;
    _head = head._next;
    head = null;

    // now _head is null or references the next command
    if (_head == null) {
      _tail = null;
    } else {
      _head.start();
    }
  }
}

(:background)
class WebRequestCommand {
  var _next;
  var _queue;
  private var _url;
  private var _callback;

  function initialize(url, callback) {
    _url = url;
    _callback = callback;
  }

  function start() {
    $.logMessage("Fetching: " + _url);
    Communications.makeWebRequest(
      _url,
      null,
      {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      },
      method(:handleResponse)
    );
  }

  function handleResponse(
    responseCode as Number,
    data as Null or Dictionary or String
  ) as Void {
    $.logMessage("Response: " + responseCode);
    _callback.invoke(responseCode, data);
    _callback = null;

    // remove self from the queue, start the next request
    finish();
  }

  function finish() {
    var queue = _queue;
    _queue = null;

    if (queue != null) {
      queue.finishCommand();
    }
  }
}
