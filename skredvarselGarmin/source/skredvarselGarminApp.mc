import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

using Toybox.Background;
using Toybox.Application.Storage;

(:background)
class skredvarselGarminApp extends Application.AppBase {
  private var _skredvarselStorage as SkredvarselStorage =
    new SkredvarselStorage();
  private var _skredvarselApi as SkredvarselApi = new SkredvarselApi(
    _skredvarselStorage
  );

  var REFRESH_INTERVAL_MINUTES = 120;

  function initialize() {
    AppBase.initialize();
  }

  private function registerTemporalEvent() {
    var lastRunTime = Background.getLastTemporalEventTime();

    var now = new Time.Moment(Time.now().value());

    var refreshInterval = new Time.Duration(REFRESH_INTERVAL_MINUTES * 60);
    var registeredEvent = Background.getTemporalEventRegisteredTime();
    if (lastRunTime == null) {
      $.logMessage("Background refresh never done. Running immediately.");
      Background.registerForTemporalEvent(now);
    } else if (
      registeredEvent == null ||
      registeredEvent.value() != refreshInterval.value()
    ) {
      $.logMessage(
        "Registering temporal event in " + REFRESH_INTERVAL_MINUTES + " minutes"
      );
      Background.registerForTemporalEvent(refreshInterval);
    }
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    registerTemporalEvent();
    return (
      [
        new ForecastMenu(_skredvarselApi, _skredvarselStorage),
        new ForecastMenuInputDelegate(_skredvarselApi, _skredvarselStorage),
      ] as Array<Views or InputDelegates>
    );
  }

  (:glance)
  function getGlanceView() {
    registerTemporalEvent();
    return [new GlanceView(_skredvarselApi, _skredvarselStorage)];
  }

  function getServiceDelegate() as Array<System.ServiceDelegate> {
    return [new ServiceDelegate(_skredvarselApi, _skredvarselStorage)];
  }

  public function onBackgroundData(data as Boolean?) as Void {
    if (data) {
      WatchUi.requestUpdate();
    }

    registerTemporalEvent();
  }
}

function getApp() as skredvarselGarminApp {
  return Application.getApp() as skredvarselGarminApp;
}
