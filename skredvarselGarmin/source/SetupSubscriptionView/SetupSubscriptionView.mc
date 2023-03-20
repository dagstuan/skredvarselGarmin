import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;

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
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON,
      },
    },
    callback
  );
}

class SetupSubscriptionView extends Ui.View {
  private var _loadingView as LoadingView?;

  function initialize() {
    View.initialize();
  }

  function onShow() {
    _loadingView = new LoadingView();
    Ui.pushView(_loadingView, new LoadingViewDelegate(), Ui.SLIDE_BLINK);
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
      Ui.popView(Ui.SLIDE_BLINK);
      _loadingView = null;
    }

    if (responseCode == 200) {
      var response = data as SetupSubscriptionResponse;
      var status = response["status"];

      if (status.equals("SEEN_WATCH_ACTIVE_SUBSCRIPTION")) {
        $.setHasSubscription(true);
        var initialView = $.getInitialForecastView();
        Ui.switchToView(initialView[0], initialView[1], Ui.SLIDE_BLINK);
      } else if (status.equals("SEEN_WATCH_INACTIVE_SUBSCRIPTION")) {
        Ui.switchToView(
          new NoSubscriptionView(
            "Gå til skredvarsel.app på mobil for å tegne abonnement til appen."
          ),
          null,
          Ui.SLIDE_BLINK
        );
      } else if (status.equals("NEW_WATCH")) {
        Ui.switchToView(
          new NoSubscriptionView(
            "Logg inn på skredvarsel.app på mobilen, og legg til klokken med koden:\n\n" +
              response["addWatchKey"]
          ),
          null,
          Ui.SLIDE_BLINK
        );
      }
    } else {
      Ui.switchToView(
        new TextAreaView(
          "Fikk ikke til å sjekke for abonnement. Prøv å koble til telefonen på nytt."
        ),
        new TextAreaViewDelegate(),
        Ui.SLIDE_BLINK
      );
    }
  }
}
