import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

using Toybox.WatchUi as Ui;
using Toybox.Background;
using Toybox.Application.Storage;

(:background)
class skredvarselGarminApp extends Application.AppBase {
  const REFRESH_INTERVAL_MINUTES = 60;
  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    $.setHasSubscription(false);
    $.resetStorageCacheIfRequired();
  }

  private function registerTemporalEvent() {
    var lastRunTime = Background.getLastTemporalEventTime();

    var now = new Time.Moment(Time.now().value());

    var refreshInterval = new Time.Duration(REFRESH_INTERVAL_MINUTES * 60);
    var registeredEvent = Background.getTemporalEventRegisteredTime();
    if (lastRunTime == null) {
      if ($.Debug) {
        $.logMessage("Background refresh never done. Running immediately.");
      }
      Background.registerForTemporalEvent(now);
    } else if (
      registeredEvent == null ||
      registeredEvent.value() != refreshInterval.value()
    ) {
      if ($.Debug) {
        $.logMessage(
          "Registering temporal event in " +
            REFRESH_INTERVAL_MINUTES +
            " minutes"
        );
      }
      Background.registerForTemporalEvent(refreshInterval);
    }
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Ui.Views or Ui.InputDelegates>? {
    registerTemporalEvent();

    if ($.getHasSubscription() == false) {
      if ($.Debug) {
        $.logMessage("No subscription detected.");
      }
      return [new SetupSubscriptionView(), new SetupSubscriptionViewDelegate()];
    }

    var deviceSettings = System.getDeviceSettings();
    if (
      deviceSettings has :isGlanceModeEnabled &&
      deviceSettings.isGlanceModeEnabled
    ) {
      var monkeyVersion = deviceSettings.monkeyVersion;

      if (monkeyVersion[0] < 4) {
        // CIQ less than 4 does not support having a menu as
        // a main view. Need to use an intermediate view.
        return [new IntermediateBaseView()];
      }

      return [new ForecastMenu(), new ForecastMenuDelegate()];
    }

    return [new WidgetView(), new WidgetViewDelegate()];
  }

  (:glance)
  public function getGlanceView() as Lang.Array<Ui.GlanceView>? {
    return [new GlanceView()];
  }

  function getServiceDelegate() as Array<System.ServiceDelegate> {
    return [new ServiceDelegate()];
  }

  public function onBackgroundData(
    fetchedData as Application.PersistableType
  ) as Void {
    if ($.Debug) {
      $.logMessage("Exited background job.");
    }

    if (fetchedData) {
      Ui.requestUpdate();
    }

    registerTemporalEvent();
  }
}

function getApp() as skredvarselGarminApp {
  return Application.getApp() as skredvarselGarminApp;
}
