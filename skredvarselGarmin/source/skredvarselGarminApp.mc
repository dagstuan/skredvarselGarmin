import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

using Toybox.WatchUi as Ui;
using Toybox.Background;
using Toybox.Application.Storage;

(:background)
class skredvarselGarminApp extends Application.AppBase {
  const REFRESH_INTERVAL_MINUTES = 60;
  const STORAGE_VERSION = 2;

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    var storageVersion = Storage.getValue("storageVersion") as Number?;

    if (storageVersion == null || storageVersion != STORAGE_VERSION) {
      $.logMessage("Wrong storage version detected. Resetting cache");
      $.resetStorageCache();
      Storage.setValue("storageVersion", STORAGE_VERSION);
    }
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
  function getInitialView() as Array<Ui.Views or Ui.InputDelegates>? {
    registerTemporalEvent();

    var mainView = new ForecastMenu();
    var mainViewDelegate = new ForecastMenuInputDelegate();

    var deviceSettings = System.getDeviceSettings();
    if (
      deviceSettings has :isGlanceModeEnabled &&
      deviceSettings.isGlanceModeEnabled
    ) {
      var monkeyVersion = deviceSettings.monkeyVersion;

      if (monkeyVersion[0] < 4) {
        // CIQ less than 4 does not support having a menu as
        // a main view. Need to use an intermediate view.
        return [new IntermediateBaseView(mainView, mainViewDelegate)];
      }

      return [mainView, mainViewDelegate];
    }

    return [
      new WidgetView(),
      new WidgetViewDelegate(mainView, mainViewDelegate),
    ];
  }

  (:glance)
  function getGlanceView() {
    registerTemporalEvent();

    var favoriteRegionId = $.getFavoriteRegionId();

    if (favoriteRegionId == null) {
      return null;
    }

    return [
      new GlanceView({
        :regionId => favoriteRegionId,
        :useBufferedBitmap => true, // TODO: set this based on device.
      }),
    ];
  }

  function getServiceDelegate() as Array<System.ServiceDelegate> {
    return [new ServiceDelegate()];
  }

  public function onBackgroundData(fetchedData as Boolean?) as Void {
    $.logMessage("Exited background job.");

    if (fetchedData) {
      Ui.requestUpdate();
    }

    registerTemporalEvent();
  }
}

function getApp() as skredvarselGarminApp {
  return Application.getApp() as skredvarselGarminApp;
}
