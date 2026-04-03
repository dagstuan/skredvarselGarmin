import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

using Toybox.Application.Storage;

using Toybox.WatchUi as Ui;
using Toybox.Background;
using Toybox.Time;

(:background)
class DatafieldApp extends Application.AppBase {
  private var _rootView as DatafieldRootView? = null;

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state as Dictionary?) {
    $.resetStorageCacheIfRequired();
  }

  function getInitialView() as [Ui.Views] or [Ui.Views, Ui.InputDelegates] {
    // If the user has toggled the reset setting, clear the stored 401 denial
    // so the background will retry. Reset the setting back to false afterwards.
    var resetSubscription =
      Application.Properties.getValue("resetSubscription") as Boolean;
    if (resetSubscription) {
      $.setHasSubscription(true);
      Application.Properties.setValue("resetSubscription", false);
    }

    var showSubscription = !$.getHasSubscription();
    if (!showSubscription) {
      $.registerTemporalEvent();
      _maybeQueueImmediateBackgroundFetch();
    }

    _rootView = new DatafieldRootView(showSubscription);
    return [_rootView];
  }

  public function getRootView() as DatafieldRootView? {
    return _rootView;
  }

  (:foregroundRequest)
  private function _maybeQueueImmediateBackgroundFetch() as Void {
    if ($.Debug) {
      $.log(
        "_maybeQueueImmediateBackgroundFetch: foreground device, skipping."
      );
    }
  }

  (:noForegroundRequest)
  private function _maybeQueueImmediateBackgroundFetch() as Void {
    if ($.getBackgroundFetchingEnabled() == false) {
      if ($.Debug) {
        $.log(
          "_maybeQueueImmediateBackgroundFetch: background fetching disabled."
        );
      }
      return;
    }

    if ($.Debug) {
      $.log("_maybeQueueImmediateBackgroundFetch: queuing background fetch.");
    }
    $.queueImmediateBackgroundJob();
  }

  function getServiceDelegate() {
    return [new DatafieldServiceDelegate()];
  }

  public function onBackgroundData(
    fetchedData as Application.PersistableType
  ) as Void {
    if ($.Debug) {
      $.log(
        Lang.format("Exited background job. Fetched data: $1$", [fetchedData])
      );
    }

    if (
      fetchedData == true ||
      fetchedData == $.BACKGROUND_SUBSCRIPTION_RESULT
    ) {
      if (_rootView != null) {
        _rootView.onDataChanged();
      }
      Ui.requestUpdate();
    }

    $.registerTemporalEvent();
  }
}

function getApp() as DatafieldApp {
  return Application.getApp() as DatafieldApp;
}
