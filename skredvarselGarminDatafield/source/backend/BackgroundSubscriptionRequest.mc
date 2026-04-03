import Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.System;

const BACKGROUND_SUBSCRIPTION_REQUEST_SETUP = "setupSubscription";
const BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_ADD_WATCH = "checkAddWatch";
const BACKGROUND_SUBSCRIPTION_REQUEST_CHECK_SUBSCRIPTION = "checkSubscription";
const BACKGROUND_SUBSCRIPTION_RESULT = "subscriptionBackgroundRequest";

const BACKGROUND_SUBSCRIPTION_REQUEST_STORAGE_KEY =
  "backgroundSubscriptionRequest";
const BACKGROUND_SUBSCRIPTION_RESPONSE_STORAGE_KEY =
  "backgroundSubscriptionResponse";

(:background)
function queueBackgroundSubscriptionRequest(requestType as String) as Void {
  if ($.Debug) {
    $.log(
      Lang.format("Queueing background subscription request $1$", [requestType])
    );
  }

  Storage.setValue(BACKGROUND_SUBSCRIPTION_REQUEST_STORAGE_KEY, {
    "requestType" => requestType,
    "pending" => true,
  });
  clearBackgroundSubscriptionResponse();
}

(:background)
function getLatestBackgroundSubscriptionRequest() as Dictionary? {
  return (
    Storage.getValue(BACKGROUND_SUBSCRIPTION_REQUEST_STORAGE_KEY) as Dictionary?
  );
}

(:background)
function getPendingBackgroundSubscriptionRequest() as Dictionary? {
  var request = $.getLatestBackgroundSubscriptionRequest();
  if (request == null) {
    return null;
  }

  var isPending = request["pending"] as Boolean?;
  return isPending == true ? request : null;
}

(:background)
function getLatestBackgroundSubscriptionResponse() as Dictionary? {
  return (
    Storage.getValue(BACKGROUND_SUBSCRIPTION_RESPONSE_STORAGE_KEY) as
    Dictionary?
  );
}

(:background)
function completeBackgroundSubscriptionRequest(
  request as Dictionary,
  responseCode as Number,
  data as WebRequestCallbackData
) as Void {
  var requestType = request["requestType"] as String;
  var storedData = data != null ? data : "";

  if ($.Debug) {
    $.log(
      Lang.format("Completed background subscription request $1$ with $2$", [
        requestType,
        responseCode,
      ])
    );
  }

  Storage.setValue(BACKGROUND_SUBSCRIPTION_REQUEST_STORAGE_KEY, {
    "requestType" => requestType,
    "pending" => false,
  });
  Storage.setValue(BACKGROUND_SUBSCRIPTION_RESPONSE_STORAGE_KEY, {
    "requestType" => requestType,
    "responseCode" => responseCode,
    "data" => storedData,
    "handled" => false,
  });
}

(:background)
function clearBackgroundSubscriptionResponse() as Void {
  Storage.setValue(BACKGROUND_SUBSCRIPTION_RESPONSE_STORAGE_KEY, {
    "handled" => true,
  });
}

(:background)
function markBackgroundSubscriptionResponseHandled() as Void {
  var response = $.getLatestBackgroundSubscriptionResponse();
  if (response == null) {
    return;
  }

  response["handled"] = true;
  Storage.setValue(BACKGROUND_SUBSCRIPTION_RESPONSE_STORAGE_KEY, response);
}
