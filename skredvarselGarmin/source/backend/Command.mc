import Toybox.Lang;

using Toybox.Communications;
using Toybox.System;

(:glance)
var commandQueue as CommandExecutor? = null;

(:glance)
class CommandExecutor {
  private var _head as WebRequestCommand?;
  private var _tail as WebRequestCommand?;

  function initialize() {
    _head = null;
    _tail = null;
  }

  function addCommand(path, storageKey, callback) {
    var command = new WebRequestCommand(path, storageKey, callback);

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

(:glance)
class WebRequestCommand {
  var _next;
  var _queue;
  private var _path;
  private var _storageKey;
  private var _callback;

  function initialize(path as String, storageKey as String, callback) {
    _path = path;
    _storageKey = storageKey;
    _callback = callback;
  }

  function start() {
    var delegate = new WebRequestDelegate(
      _path,
      _storageKey,
      method(:handleResponse)
    );
    delegate.makeRequest();
  }

  function handleResponse(
    responseCode as Number,
    data as Null or Dictionary or String
  ) as Void {
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
