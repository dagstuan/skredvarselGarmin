import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

using Toybox.WatchUi as Ui;
using Toybox.Background;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.Position;

(:glance)
function registerTemporalEvent() {
  if ($.getHasSubscription() == false) {
    if ($.Debug) {
      $.log("No subscription detected. Removing temporal event.");
    }
    Background.deleteTemporalEvent();
    return;
  }

  var lastRunTime = Background.getLastTemporalEventTime();

  if (lastRunTime == null) {
    if ($.Debug) {
      $.log("Background refresh never done. Running immediately.");
    }

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
      if ($.Debug) {
        $.log(
          Lang.format("Registering temporal event in $1$ seconds", [
            refreshInterval.value(),
          ])
        );
      }

      Background.registerForTemporalEvent(refreshInterval);
    } else if ($.Debug) {
      $.log(
        Lang.format("Temporal event already registered in $1$ seconds", [
          refreshInterval.value(),
        ])
      );
    }
  }
}

function getInitialViewAndDelegate() as [ Ui.Views, Ui.InputDelegates? ] {
  var deviceSettings = System.getDeviceSettings();
  if (
    deviceSettings has :isGlanceModeEnabled &&
    deviceSettings.isGlanceModeEnabled
  ) {
    var monkeyVersion = deviceSettings.monkeyVersion;

    if (monkeyVersion[0] < 4) {
      // CIQ less than 4 does not support having a menu as
      // a main view. Need to use an intermediate view.
      return [new IntermediateBaseView(), null];
    }

    return [new ForecastMenu(), new ForecastMenuDelegate()];
  }

  return [new WidgetView(), new WidgetViewDelegate()];
}

function switchToInitialView(transition as Ui.SlideType) {
  $.registerTemporalEvent();

  var initialViewAndDelegate = $.getInitialViewAndDelegate();

  Ui.switchToView(initialViewAndDelegate[0], initialViewAndDelegate[1], transition);
}

(:background)
class skredvarselGarminApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function onStart(state as Dictionary?) {
    $.resetStorageCacheIfRequired();
    $.updateComplicationIfExists();
  }

  (:glance)
  public function onReceive(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    if (responseCode == 200) {
      if ($.Debug) {
        $.log("Received location forecast from server.");
      }
      Ui.requestUpdate();
    }
  }

  (:glance)
  function onPosition(info as Position.Info) as Void {
    var degrees = info.position.toDegrees();
    $.saveLocation(degrees);
    $.loadSimpleForecastForLocation(method(:onReceive), false);
  }

  (:glance)
  function fetchPositionIfStale() {
    if ($.getUseLocation()) {
      var location = $.getLocation();
      var lastLocationTime = $.getLastLocationTime();

      var dataAge = Time.now().compare(new Time.Moment(lastLocationTime));
      if (location == null || lastLocationTime == null || dataAge > $.TIME_TO_CONSIDER_DATA_STALE) {
        if ($.Debug) {
          $.log("Location is stale. Fetching new location.");
        }

        Position.enableLocationEvents(
          Position.LOCATION_ONE_SHOT,
          method(:onPosition)
        );
      }
    }
  }

  function getInitialView() as [ Ui.Views ] or [ Ui.Views, Ui.InputDelegates ] {
    if ($.getHasSubscription() == false) {
      if ($.Debug) {
        $.log("No subscription detected.");
      }

      return [new SetupSubscriptionView(), new SetupSubscriptionViewDelegate()];
    }

    $.registerTemporalEvent();

    fetchPositionIfStale();
    var initialViewAndDelegate = $.getInitialViewAndDelegate();

    if (initialViewAndDelegate[1] != null) {
      return initialViewAndDelegate;
    } else {
      return [initialViewAndDelegate[0]];
    }
  }

  (:glance)
  public function getGlanceView() {
    $.registerTemporalEvent();
    fetchPositionIfStale();

    return [new GlanceView()];
  }

  function getServiceDelegate() {
    return [new ServiceDelegate()];
  }

  public function onBackgroundData(
    fetchedData as Application.PersistableType
  ) as Void {
    if ($.Debug) {
      $.log(
        Lang.format("Exited background job. Fetched data: $1$", [fetchedData])
      );
    }

    if (fetchedData == true) {
      Ui.requestUpdate();
    }

    $.registerTemporalEvent();
  }
}

function getApp() as skredvarselGarminApp {
  return Application.getApp() as skredvarselGarminApp;
}
