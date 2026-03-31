import Toybox.Lang;
import Toybox.System;

using Toybox.Time;
using Toybox.Time.Gregorian;

(:background)
class DatafieldServiceDelegate extends System.ServiceDelegate {
  public function initialize() {
    ServiceDelegate.initialize();
  }

  public function onTemporalEvent() as Void {
    if ($.Debug) {
      $.log("Datafield temporal event triggered.");
    }

    if ($.canMakeWebRequest() == false) {
      if ($.Debug) {
        $.log("No connection available. Skipping reload.");
      }

      Background.exit(false);
      return;
    }

    if ($.getLocation() == null) {
      if ($.Debug) {
        $.log("No location available. Skipping reload.");
      }

      Background.exit(false);
      return;
    }

    $.loadDetailedWarningsForLocation(method(:onDetailedForecastLoaded), false);
  }

  public function onDetailedForecastLoaded(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    if ($.Debug) {
      $.log(
        Lang.format("Detailed forecast loaded. Response code: $1$", [
          responseCode,
        ])
      );
    }
    Background.exit(responseCode == 200);
  }
}
