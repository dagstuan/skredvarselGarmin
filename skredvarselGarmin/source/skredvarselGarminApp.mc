import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

using Toybox.WatchUi as Ui;
using Toybox.Background;
using Toybox.Time.Gregorian;

function getInitialViewAndDelegate() as Array<Ui.Views or Ui.InputDelegates> {
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

function switchToInitialView(transition as Ui.SlideType) {
  var initialViewAndDelegate = $.getInitialViewAndDelegate();

  var view = initialViewAndDelegate[0];
  var delegate =
    initialViewAndDelegate.size() > 1 ? initialViewAndDelegate[1] : null;

  Ui.switchToView(view, delegate, transition);
}

(:background)
class skredvarselGarminApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    $.resetStorageCacheIfRequired();
    $.updateComplicationIfExists();
  }

  (:glance)
  private function registerTemporalEvent() {
    var lastRunTime = Background.getLastTemporalEventTime();

    if (lastRunTime == null) {
      $.log("Background refresh never done. Running immediately.");

      var now = new Time.Moment(Time.now().value());
      Background.registerForTemporalEvent(now);
    } else {
      var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

      var refreshIntervalSeconds =
        today.month > 5 && today.month < 12
          ? Gregorian.SECONDS_PER_HOUR * 12
          : Gregorian.SECONDS_PER_HOUR;

      var refreshInterval = new Time.Duration(refreshIntervalSeconds);
      var registeredEvent = Background.getTemporalEventRegisteredTime();
      if (
        registeredEvent == null ||
        registeredEvent.value() != refreshInterval.value()
      ) {
        $.log(
          Lang.format("Registering temporal event in $1$ seconds", [
            refreshInterval.value(),
          ])
        );

        Background.registerForTemporalEvent(refreshInterval);
      }
    }
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Ui.Views or Ui.InputDelegates>? {
    registerTemporalEvent();

    if ($.getHasSubscription() == false) {
      $.log("No subscription detected.");
      return [new SetupSubscriptionView(), new SetupSubscriptionViewDelegate()];
    }

    return $.getInitialViewAndDelegate();
  }

  (:glance)
  public function getGlanceView() as Lang.Array<Ui.GlanceView>? {
    registerTemporalEvent();

    return [new GlanceView()];
  }

  function getServiceDelegate() as Array<System.ServiceDelegate> {
    return [new ServiceDelegate()];
  }

  public function onBackgroundData(
    fetchedData as Application.PersistableType
  ) as Void {
    $.log(
      Lang.format("Exited background job. Fetched data: $1$", [fetchedData])
    );

    if (fetchedData == true) {
      Ui.requestUpdate();
    }

    registerTemporalEvent();
  }
}

function getApp() as skredvarselGarminApp {
  return Application.getApp() as skredvarselGarminApp;
}
