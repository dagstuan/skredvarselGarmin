import Toybox.Lang;

using Toybox.Application.Properties;
using Toybox.Background;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:background)
function getBackgroundFetchingEnabled() as Boolean {
  var enabled = Properties.getValue("enableBackgroundFetching") as Boolean?;

  return enabled != null ? enabled : true;
}

(:background)
function registerTemporalEvent() as Void {
  if ($.getBackgroundFetchingEnabled() == false) {
    if ($.Debug) {
      $.log("Background fetching disabled. Removing temporal event.");
    }

    Background.deleteTemporalEvent();
    return;
  }

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
