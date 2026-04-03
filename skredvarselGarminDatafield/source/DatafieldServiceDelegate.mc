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
    $.clearQueuedImmediateBackgroundJob();

    if ($.Debug) {
      $.log("Datafield temporal event triggered.");
    }

    if (_handlePendingSubscriptionRequest()) {
      return;
    }

    if ($.getBackgroundFetchingEnabled() == false) {
      if ($.Debug) {
        $.log("Background fetching disabled. Skipping reload.");
      }

      Background.deleteTemporalEvent();
      Background.exit(false);
      return;
    }

    if ($.canMakeWebRequest() == false) {
      if ($.Debug) {
        $.log("No connection available. Skipping reload.");
      }

      Background.exit(false);
      return;
    }

    var location = $.getLocation();
    if (location == null) {
      if ($.Debug) {
        $.log("No location available. Skipping reload.");
      }

      Background.exit(false);
      return;
    }

    $.loadDetailedWarningsForLocation(
      location,
      method(:onDetailedForecastLoaded),
      false
    );
  }

  (:foregroundRequest)
  private function _handlePendingSubscriptionRequest() as Boolean {
    return false;
  }

  (:noForegroundRequest)
  private function _handlePendingSubscriptionRequest() as Boolean {
    var pendingSubscriptionRequest =
      $.getPendingBackgroundSubscriptionRequest();
    if (pendingSubscriptionRequest == null) {
      return false;
    }

    _runPendingSubscriptionRequest(pendingSubscriptionRequest as Dictionary);
    return true;
  }

  (:noForegroundRequest)
  private function _runPendingSubscriptionRequest(
    request as Dictionary
  ) as Void {
    if ($.canMakeWebRequest() == false) {
      if ($.Debug) {
        $.log(
          "No connection available. Skipping subscription background call."
        );
      }

      $.completeBackgroundSubscriptionRequest(request, 0, "");
      Background.exit($.BACKGROUND_SUBSCRIPTION_RESULT);
      return;
    }

    var requestType = request["requestType"] as String;
    if (requestType.equals($.BACKGROUND_SUBSCRIPTION_REQUEST_SETUP)) {
      var deviceSettings = System.getDeviceSettings();

      if ($.Debug) {
        $.log("Making background setupSubscription request.");
      }

      Communications.makeWebRequest(
        $.ApiBaseUrl + "/watch/setupSubscription",
        {
          "watchId" => deviceSettings.uniqueIdentifier,
          "partNumber" => deviceSettings.partNumber,
          "appType" => "datafield",
        },
        {
          :method => Communications.HTTP_REQUEST_METHOD_POST,
          :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
          },
        },
        method(:onPendingSubscriptionRequestResponse)
      );
    } else if (
      requestType.equals($.BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_ADD_WATCH)
    ) {
      $.makeGetRequestWithAuthorization(
        $.ApiBaseUrl + "/watch/checkAddWatch",
        method(:onPendingSubscriptionRequestResponse)
      );
    } else if (
      requestType.equals($.BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_SUBSCRIPTION)
    ) {
      $.makeGetRequestWithAuthorization(
        $.ApiBaseUrl + "/watch/checkSubscription",
        method(:onPendingSubscriptionRequestResponse)
      );
    } else {
      if ($.Debug) {
        $.log(
          Lang.format("Unknown background subscription request type: $1$", [
            requestType,
          ])
        );
      }

      $.completeBackgroundSubscriptionRequest(request, 0, "");
      Background.exit($.BACKGROUND_SUBSCRIPTION_RESULT);
    }
  }

  (:noForegroundRequest)
  public function onPendingSubscriptionRequestResponse(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    var pendingSubscriptionRequest =
      $.getPendingBackgroundSubscriptionRequest();
    if (pendingSubscriptionRequest != null) {
      $.completeBackgroundSubscriptionRequest(
        pendingSubscriptionRequest as Dictionary,
        responseCode,
        data
      );
    }

    Background.exit($.BACKGROUND_SUBSCRIPTION_RESULT);
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
