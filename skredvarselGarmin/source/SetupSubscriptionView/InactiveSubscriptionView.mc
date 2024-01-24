import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Communications as Comm;

class InactiveSubscriptionView extends Ui.View {
  private var _textArea as Ui.TextArea?;
  private var _checkSubscriptionTimer as Timer.Timer?;
  private var _numRetries as Number = 0;
  private var _maxRetries = 120;

  function initialize() {
    View.initialize();
    startTimer();

    Comm.openWebPage($.FrontendBaseUrl + "/subscribe", null, null);
  }

  function onLayout(dc as Gfx.Dc) {
    var text = $.getOrLoadResourceString(
      "Gå til skredvarsel.app på mobil for å tegne abonnement til appen.",
      :SeenWatchInactiveSubscription
    );

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

  function onUpdate(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.clear();
    if (_textArea != null) {
      _textArea.draw(dc);
    }
  }

  function onHide() {
    if (_checkSubscriptionTimer != null) {
      _checkSubscriptionTimer.stop();
    }

    _checkSubscriptionTimer = null;
  }

  function startTimer() {
    if (_checkSubscriptionTimer == null) {
      _checkSubscriptionTimer = new Timer.Timer();
    }

    _checkSubscriptionTimer.start(
      method(:onTimerTrigged),
      5000 /* ms */,
      false
    );
  }

  function onTimerTrigged() as Void {
    Comm.makeWebRequest(
      $.ApiBaseUrl + "/watch/checkSubscription",
      null,
      {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "Authorization" => Lang.format("Garmin $1$", [
            $.getDeviceIdentifier(),
          ]),
        },
      },
      method(:onCheckSubscriptionResponse)
    );
  }

  function onCheckSubscriptionResponse(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      $.setHasSubscriptionAndSwitchToInitialView();
    } else if (responseCode == 401) {
      _numRetries += 1;
      if (_numRetries >= _maxRetries) {
        $.switchedToFailedSubscriptionSetupView();
      } else {
        startTimer();
      }
    }
  }
}
