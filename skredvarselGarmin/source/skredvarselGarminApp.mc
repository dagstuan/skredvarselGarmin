import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

using Toybox.Background;
using Toybox.Application.Storage;

(:background)
class skredvarselGarminApp extends Application.AppBase {
  var skredvarselApi as SkredvarselApi = new SkredvarselApi();

  var REFRESH_INTERVAL_MINUTES = 120;

  function initialize() {
    AppBase.initialize();

    Storage.setValue(FavoriteRegionIdStorageKey, "3022");
  }

  function onStart(state) {
    if (Background.getTemporalEventRegisteredTime() != null) {
      Background.registerForTemporalEvent(
        new Time.Duration(REFRESH_INTERVAL_MINUTES * 60)
      );
    }
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    return (
      [new ForecastMenu(skredvarselApi), new ForecastMenuInputDelegate()] as
      Array<Views or InputDelegates>
    );
  }

  (:glance)
  function getGlanceView() {
    return [new GlanceView(skredvarselApi)];
  }

  function getServiceDelegate() as Array<System.ServiceDelegate> {
    return [new ServiceDelegate(skredvarselApi)];
  }

  public function onBackgroundData(data as Boolean?) as Void {
    if (data) {
      WatchUi.requestUpdate();
    }
  }
}

function getApp() as skredvarselGarminApp {
  return Application.getApp() as skredvarselGarminApp;
}
