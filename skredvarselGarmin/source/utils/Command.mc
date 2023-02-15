import Toybox.Lang;

using Toybox.Communications;

(:background)
class Command {
  var _next;
  var _queue;

  function initialize() {
    _next = null;
    _queue = null;
  }

  function start() {}

  function finish() {
    var queue = _queue;
    _queue = null;

    if (queue != null) {
      queue.finishCommand();
    }
  }
}

(:background)
class CommandExecutor {
  hidden var _head;
  hidden var _tail;

  function initialize() {
    _head = null;
    _tail = null;
  }

  function addCommand(command) {
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
class WebRequestCommand extends Command {
  hidden var _url;
  hidden var _params;
  hidden var _options;
  hidden var _callback;

  function initialize(url, params, options, callback) {
    Command.initialize();
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
    Command.finish();
  }
}
