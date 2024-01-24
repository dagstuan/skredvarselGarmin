import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Communications as Comm;

class AddWatchView extends Ui.View {
  private var _textArea as Ui.TextArea?;
  private var _checkAddWatchTimer as Timer.Timer?;
  private var _addWatchKey as String;
  private var _numRetries as Number = 0;
  private var _maxRetries = 120;

  function initialize(addWatchKey as String) {
    View.initialize();
    startTimer();
    _addWatchKey = addWatchKey;

    Comm.openWebPage($.FrontendBaseUrl + "/addwatch", null, null);
  }

  function onLayout(dc as Gfx.Dc) {
    var text = Lang.format("$1$\n\n$2$", [
      $.getOrLoadResourceString(
        "Logg inn på skredvarsel.app på mobilen, og legg til klokken med koden:",
        :NewWatch
      ),
      _addWatchKey,
    ]);

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
    if (_checkAddWatchTimer != null) {
      _checkAddWatchTimer.stop();
    }

    _checkAddWatchTimer = null;
  }

  function startTimer() {
    if (_checkAddWatchTimer == null) {
      _checkAddWatchTimer = new Timer.Timer();
    }

    _checkAddWatchTimer.start(method(:onTimerTrigged), 5000 /* ms */, false);
  }

  function onTimerTrigged() as Void {
    Comm.makeWebRequest(
      $.ApiBaseUrl + "/watch/checkAddWatch",
      null,
      {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "Authorization" => Lang.format("Garmin $1$", [
            $.getDeviceIdentifier(),
          ]),
        },
      },
      method(:onCheckAddWatchResponse)
    );
  }

  function onCheckAddWatchResponse(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      var response = data as SetupSubscriptionResponse;
      var status = response["status"];

      if (status.equals("ACTIVE_SUBSCRIPTION")) {
        $.setHasSubscriptionAndSwitchToInitialView();
      } else {
        $.switchToInactiveSubscriptionView();
      }
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
