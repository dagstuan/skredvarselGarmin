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

  function addCommand(command as WebRequestCommand) {
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
    head._next = null;
    head._queue = null;

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
  hidden var _url;
  hidden var _params;
  hidden var _options;
  hidden var _callback;

  function initialize(url, params, options, callback) {
    _url = url;
    _params = params;
    _options = options;
    _callback = callback;
  }

  function start() {
    $.logMessage("Fetching: " + _url);
    Communications.makeWebRequest(
      _url,
      _params,
      _options,
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
