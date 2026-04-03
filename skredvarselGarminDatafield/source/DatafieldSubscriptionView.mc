import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.System;

// Subscription states
enum SubscriptionState {
  STATE_CHECKING, // Waiting for setupSubscription response
  STATE_ADD_WATCH, // New watch — show key, poll checkAddWatch
  STATE_INACTIVE, // Watch known but no subscription, poll checkSubscription
  STATE_FAILED, // Too many retries
}

class DatafieldSubscriptionView {
  private var _state as SubscriptionState = STATE_CHECKING;
  private var _addWatchKey as String = "";
  private var _numRetries as Number = 0;
  private const MAX_RETRIES = 120;
  private const POLL_INTERVAL_TICKS = 5;

  private var _started as Boolean = false;
  private var _waitingForResponse as Boolean = false;
  private var _pendingPoll as Lang.Method? = null;
  private var _ticksSinceLastPoll as Number = 0;

  private var _textArea as Ui.TextArea?;
  private var _lastDcWidth as Number = 0;
  private var _lastDcHeight as Number = 0;
  private var _lastRenderedText as String = "";

  public function initialize() {}

  public function onShow() as Void {
    if (_started) {
      _consumePendingBackgroundSubscriptionResponse();
      return;
    }

    _started = true;
    _consumePendingBackgroundSubscriptionResponse();
    if (
      _state == STATE_CHECKING &&
      _waitingForResponse == false &&
      _pendingPoll == null
    ) {
      _setupSubscription();
    }
  }

  public function onHide() as Void {
    _ticksSinceLastPoll = 0;
  }

  public function compute() as Void {
    _consumePendingBackgroundSubscriptionResponse();
    _requestCountdownUpdate();

    if (_waitingForResponse || _pendingPoll == null || _state == STATE_FAILED) {
      return;
    }

    _ticksSinceLastPoll++;
    if (_ticksSinceLastPoll >= POLL_INTERVAL_TICKS) {
      _ticksSinceLastPoll = 0;
      _waitingForResponse = true;
      (_pendingPoll as Lang.Method).invoke();
    }
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    var w = dc.getWidth();
    var h = dc.getHeight();
    var text = _getDisplayText();

    if (
      _textArea == null ||
      w != _lastDcWidth ||
      h != _lastDcHeight ||
      text != _lastRenderedText
    ) {
      _lastDcWidth = w;
      _lastDcHeight = h;
      _lastRenderedText = text;
      _buildTextArea(dc, text);
    }

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.clear();
    if (_textArea != null) {
      (_textArea as Ui.TextArea).draw(dc);
    }
  }

  public function onDataChanged() as Void {
    _consumePendingBackgroundSubscriptionResponse();
  }

  private function _buildTextArea(dc as Gfx.Dc, text as String) as Void {
    _textArea = new Ui.TextArea({
      :text => text,
      :color => Gfx.COLOR_WHITE,
      :font => [Gfx.FONT_MEDIUM, Gfx.FONT_SMALL, Gfx.FONT_XTINY],
      :locX => Ui.LAYOUT_HALIGN_CENTER,
      :locY => Ui.LAYOUT_VALIGN_CENTER,
      :justification => Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER,
      :width => dc.getWidth() * 0.8,
      :height => dc.getHeight() * 0.8,
    });
  }

  private function _getDisplayText() as String {
    var text;
    if (_state == STATE_CHECKING) {
      text = $.getOrLoadResourceString(
        "Checking subscription...",
        :CheckingSubscription
      );
    } else if (_state == STATE_ADD_WATCH) {
      text = Lang.format("$1$\n\n$2$", [
        $.getOrLoadResourceString(
          "Log in to skredvarsel.app on your phone and add the watch with the code:",
          :NewWatch
        ),
        _addWatchKey,
      ]);
    } else if (_state == STATE_INACTIVE) {
      text = $.getOrLoadResourceString(
        "Go to skredvarsel.app on your phone to subscribe to the app.",
        :SeenWatchInactiveSubscription
      );
    } else {
      text = $.getOrLoadResourceString(
        "Failed to set up subscription. Exit the app and try again.",
        :FailedToSetupSubscription
      );
    }

    return text + _getBackgroundCountdownText();
  }

  private function _setState(state as SubscriptionState) as Void {
    _state = state;
    _textArea = null;
    _lastRenderedText = "";
    Ui.requestUpdate();
  }

  private function _queuePendingPoll(pollMethod as Lang.Method?) as Void {
    _pendingPoll = pollMethod;
    _ticksSinceLastPoll = 0;
  }

  private function _handleRetryableFailure(nextPoll as Lang.Method?) as Void {
    _numRetries++;
    if (_numRetries >= MAX_RETRIES) {
      _pendingPoll = null;
      _ticksSinceLastPoll = 0;
      _setState(STATE_FAILED);
      return;
    }

    _queuePendingPoll(nextPoll);
  }

  (:foregroundRequest)
  private function _getBackgroundCountdownText() as String {
    return "";
  }

  (:noForegroundRequest)
  private function _getBackgroundCountdownText() as String {
    if (_waitingForResponse == false || _state == STATE_FAILED) {
      return "";
    }

    var secondsRemaining = $.getQueuedImmediateBackgroundJobSecondsRemaining();
    if (secondsRemaining <= 0) {
      return "";
    }

    return Lang.format("\n\nNext background check in $1$s.", [
      secondsRemaining,
    ]);
  }

  (:foregroundRequest)
  private function _requestCountdownUpdate() as Void {}

  (:noForegroundRequest)
  private function _requestCountdownUpdate() as Void {
    if (
      _waitingForResponse &&
      $.getQueuedImmediateBackgroundJobSecondsRemaining() > 0
    ) {
      Ui.requestUpdate();
    }
  }

  (:foregroundRequest)
  private function _setupSubscription() as Void {
    if ($.Debug) {
      $.log("DatafieldSubscriptionView: calling setupSubscription.");
    }
    _ticksSinceLastPoll = 0;
    _waitingForResponse = true;
    var deviceSettings = System.getDeviceSettings();
    Comm.makeWebRequest(
      $.ApiBaseUrl + "/watch/setupSubscription",
      {
        "watchId" => deviceSettings.uniqueIdentifier,
        "partNumber" => deviceSettings.partNumber,
        "appType" => "datafield",
      },
      {
        :method => Comm.HTTP_REQUEST_METHOD_POST,
        :headers => {
          "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON,
        },
      },
      method(:onSetupSubscriptionResponse)
    );
  }

  (:noForegroundRequest)
  private function _setupSubscription() as Void {
    _startBackgroundSubscriptionRequest(
      $.BACKGROUND_SUBSCRIPTION_REQUEST_SETUP
    );
  }

  public function onSetupSubscriptionResponse(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    _waitingForResponse = false;
    if ($.Debug) {
      $.log(Lang.format("setupSubscription response: $1$", [responseCode]));
    }

    if (responseCode == 200) {
      var response = data as Dictionary;
      var status = response["status"] as String;
      if (status.equals("SEEN_WATCH_ACTIVE_SUBSCRIPTION")) {
        switchToForecastView();
      } else if (status.equals("SEEN_WATCH_INACTIVE_SUBSCRIPTION")) {
        _setState(STATE_INACTIVE);
        _openSubscriptionPage();
        _queuePendingPoll(method(:pollCheckSubscription));
      } else if (status.equals("NEW_WATCH")) {
        _addWatchKey = response["addWatchKey"] as String;
        _setState(STATE_ADD_WATCH);
        _openAddWatchPage();
        _queuePendingPoll(method(:pollCheckAddWatch));
      }
    } else {
      _handleRetryableFailure(method(:retrySetupSubscription));
    }
  }

  public function retrySetupSubscription() as Void {
    _setupSubscription();
  }

  (:foregroundRequest)
  public function pollCheckAddWatch() as Void {
    $.makeGetRequestWithAuthorization(
      $.ApiBaseUrl + "/watch/checkAddWatch",
      method(:onCheckAddWatchResponse)
    );
  }

  (:noForegroundRequest)
  public function pollCheckAddWatch() as Void {
    _startBackgroundSubscriptionRequest(
      $.BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_ADD_WATCH
    );
  }

  public function onCheckAddWatchResponse(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    _waitingForResponse = false;
    if (responseCode == 200) {
      var status = (data as Dictionary)["status"] as String;
      if (status.equals("ACTIVE_SUBSCRIPTION")) {
        switchToForecastView();
      } else {
        _setState(STATE_INACTIVE);
        _queuePendingPoll(method(:pollCheckSubscription));
      }
    } else {
      _handleRetryableFailure(method(:pollCheckAddWatch));
    }
  }

  (:foregroundRequest)
  public function pollCheckSubscription() as Void {
    $.makeGetRequestWithAuthorization(
      $.ApiBaseUrl + "/watch/checkSubscription",
      method(:onCheckSubscriptionResponse)
    );
  }

  (:noForegroundRequest)
  public function pollCheckSubscription() as Void {
    _startBackgroundSubscriptionRequest(
      $.BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_SUBSCRIPTION
    );
  }

  public function onCheckSubscriptionResponse(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    _waitingForResponse = false;
    if (responseCode == 200) {
      switchToForecastView();
    } else {
      _handleRetryableFailure(method(:pollCheckSubscription));
    }
  }

  function switchToForecastView() as Void {
    $.setHasSubscription(true);
    $.registerTemporalEvent();
    var rootView = $.getApp().getRootView();
    if (rootView != null) {
      rootView.showForecastView();
    }
  }

  (:foregroundRequest)
  private function _openSubscriptionPage() as Void {
    Comm.openWebPage($.FrontendBaseUrl + "/subscribe", null, null);
  }

  (:noForegroundRequest)
  private function _openSubscriptionPage() as Void {
    if ($.Debug) {
      $.log(
        "Skipping automatic subscribe page open for noForegroundRequest device."
      );
    }
  }

  (:foregroundRequest)
  private function _openAddWatchPage() as Void {
    Comm.openWebPage(
      $.FrontendBaseUrl + "/addwatch?watchKey=" + _addWatchKey,
      null,
      null
    );
  }

  (:noForegroundRequest)
  private function _openAddWatchPage() as Void {
    if ($.Debug) {
      $.log(
        "Skipping automatic add-watch page open for noForegroundRequest device."
      );
    }
  }

  (:foregroundRequest)
  private function _startBackgroundSubscriptionRequest(
    requestType as String
  ) as Void {}

  (:noForegroundRequest)
  private function _startBackgroundSubscriptionRequest(
    requestType as String
  ) as Void {
    if ($.Debug) {
      $.log(
        Lang.format("Queueing subscription background request: $1$", [
          requestType,
        ])
      );
    }

    _ticksSinceLastPoll = 0;
    _waitingForResponse = true;
    $.queueBackgroundSubscriptionRequest(requestType);
    $.queueImmediateBackgroundJob();
  }

  (:foregroundRequest)
  private function _consumePendingBackgroundSubscriptionResponse() as Void {}

  (:noForegroundRequest)
  private function _consumePendingBackgroundSubscriptionResponse() as Void {
    var latestRequest = $.getLatestBackgroundSubscriptionRequest();
    var latestResponse = $.getLatestBackgroundSubscriptionResponse();
    if (latestRequest == null || latestResponse == null) {
      return;
    }

    var isHandled = latestResponse["handled"] as Boolean?;
    if (isHandled == true) {
      return;
    }

    var requestType = latestRequest["requestType"] as String;
    var responseType = latestResponse["requestType"] as String?;
    if (responseType == null || !requestType.equals(responseType)) {
      return;
    }

    var responseCode = latestResponse["responseCode"] as Number;
    var data = latestResponse["data"] as WebRequestCallbackData;

    $.markBackgroundSubscriptionResponseHandled();

    if (requestType.equals($.BACKGROUND_SUBSCRIPTION_REQUEST_SETUP)) {
      onSetupSubscriptionResponse(responseCode, data);
    } else if (
      requestType.equals($.BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_ADD_WATCH)
    ) {
      onCheckAddWatchResponse(responseCode, data);
    } else if (
      requestType.equals($.BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_SUBSCRIPTION)
    ) {
      onCheckSubscriptionResponse(responseCode, data);
    }
  }
}
