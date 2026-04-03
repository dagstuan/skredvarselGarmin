import Toybox.Lang;

using Toybox.Application.Properties;
using Toybox.Application.Storage;
using Toybox.Background;
using Toybox.Time;
using Toybox.Time.Gregorian;

const QUEUED_IMMEDIATE_BACKGROUND_JOB_RUN_AT_STORAGE_KEY =
  "queuedImmediateBackgroundJobRunAt";

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

(:background)
function queueImmediateBackgroundJob() as Void {
  var fiveMinutes = new Time.Duration(5 * 60);
  var now = Time.now();
  var lastRun = Background.getLastTemporalEventTime();
  var runAt = lastRun != null ? lastRun.add(fiveMinutes) : now;

  if (runAt.value() < now.value()) {
    runAt = now;
  }

  Storage.setValue(
    QUEUED_IMMEDIATE_BACKGROUND_JOB_RUN_AT_STORAGE_KEY,
    runAt.value()
  );
  Background.registerForTemporalEvent(runAt);

  if ($.Debug) {
    $.log(
      Lang.format("Queued immediate background job in $1$ seconds.", [
        runAt.value() - now.value(),
      ])
    );
  }
}

(:background)
function clearQueuedImmediateBackgroundJob() as Void {
  Storage.setValue(QUEUED_IMMEDIATE_BACKGROUND_JOB_RUN_AT_STORAGE_KEY, 0);
}

(:background)
function getQueuedImmediateBackgroundJobSecondsRemaining() as Number {
  var queuedRunAt =
    Storage.getValue(QUEUED_IMMEDIATE_BACKGROUND_JOB_RUN_AT_STORAGE_KEY) as
    Number?;
  if (queuedRunAt == null || queuedRunAt <= 0) {
    return 0;
  }

  var remainingSeconds = queuedRunAt - Time.now().value();
  return remainingSeconds > 0 ? remainingSeconds : 0;
}
