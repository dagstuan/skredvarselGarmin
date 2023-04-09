import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Timer;

function setupSubscription(callback as WebRequestDelegateCallback) {
  if ($.Debug) {
    $.logMessage("Asking server to setup subscription.");
  }

  var deviceSettings = Sys.getDeviceSettings();

  Comm.makeWebRequest(
    $.BaseApiUrl + "/watch/setupSubscription",
    {
      "watchId" => deviceSettings.uniqueIdentifier,
      "partNumber" => deviceSettings.partNumber,
    },
    {
      :method => Comm.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON,
      },
    },
    callback
  );
}

class SetupSubscriptionView extends Ui.View {
  private var _firstShow as Boolean = true;
  private var _loadingView as LoadingView?;
  private var _requestFailed as Boolean;
  private var _failedTextArea as Ui.TextArea?;
  private var _retryTimer as Timer.Timer?;

  private var _numRetries as Number = 0;
  private var _maxRetries = 120;

  function initialize() {
    View.initialize();

    _requestFailed = false;
  }

  function onShow() {
    if (_firstShow) {
      _firstShow = false;
      _loadingView = new LoadingView();
      Ui.pushView(_loadingView, new LoadingViewDelegate(), Ui.SLIDE_BLINK);
      $.setupSubscription(method(:onReceive));
    }
  }

  function onUpdate(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();
    if (_requestFailed) {
      if (_failedTextArea == null) {
        _failedTextArea = new Ui.TextArea({
          :text => $.getOrLoadResourceString(
            "Fikk ikke til å sjekke for abonnement. Prøv å koble til telefonen på nytt.",
            :FailedToCheckForSubscription
          ),
          :color => Gfx.COLOR_WHITE,
          :font => [Gfx.FONT_SMALL, Gfx.FONT_XTINY],
          :locX => Ui.LAYOUT_HALIGN_CENTER,
          :locY => Ui.LAYOUT_VALIGN_CENTER,
          :justification => Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER,
          :width => dc.getWidth() * 0.8,
          :height => dc.getHeight() * 0.8,
        });
      }

      _failedTextArea.draw(dc);
    }
  }

  function onHide() {
    if (_retryTimer != null) {
      _retryTimer.stop();
    }

    _retryTimer = null;
  }

  function startRetryTimer() {
    if (_retryTimer == null) {
      _retryTimer = new Timer.Timer();
    }
    _retryTimer.start(method(:onRetryTimerTrigged), 5000 /* ms */, false);
  }

  function onRetryTimerTrigged() as Void {
    $.setupSubscription(method(:onReceive));
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if ($.Debug) {
      $.logMessage("Received response " + responseCode);
    }

    if (_loadingView != null) {
      try {
        Ui.popView(Ui.SLIDE_BLINK);
        _loadingView = null;
      } catch (ex) {
        if ($.Debug) {
          $.logMessage("Failed to pop loading view on receive.");
        }
      }
    }

    if (responseCode == 200) {
      var response = data as SetupSubscriptionResponse;
      var status = response["status"];

      if (status.equals("SEEN_WATCH_ACTIVE_SUBSCRIPTION")) {
        $.setHasSubscription(true);

        $.switchToInitialView(Ui.SLIDE_BLINK);
      } else if (status.equals("SEEN_WATCH_INACTIVE_SUBSCRIPTION")) {
        Ui.switchToView(
          new NoSubscriptionView(
            $.getOrLoadResourceString(
              "Gå til skredvarsel.app på mobil for å tegne abonnement til appen.",
              :SeenWatchInactiveSubscription
            )
          ),
          null,
          Ui.SLIDE_BLINK
        );
      } else if (status.equals("NEW_WATCH")) {
        Ui.switchToView(
          new NoSubscriptionView(
            $.getOrLoadResourceString(
              "Logg inn på skredvarsel.app på mobilen, og legg til klokken med koden:",
              :NewWatch
            ) +
              "\n\n" +
              response["addWatchKey"]
          ),
          null,
          Ui.SLIDE_BLINK
        );
      }
    } else {
      _numRetries += 1;
      if (_numRetries >= _maxRetries) {
        Ui.switchToView(
          new TextAreaView(
            $.getOrLoadResourceString(
              "Fikk ikke til å sette opp abonnement. Avslutt appen og prøv på nytt.",
              :FailedToSetupSubscription
            )
          ),
          new TextAreaViewDelegate(),
          Ui.SLIDE_BLINK
        );
      } else {
        _requestFailed = true;
        startRetryTimer();
        Ui.requestUpdate();
      }
    }
  }
}
