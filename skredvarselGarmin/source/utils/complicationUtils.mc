(:background)
public function updateComplicationIfExists() {
  if ($ has :updateComplication && Toybox has :Complications) {
    $.updateComplication();
  }
}

(:hasComplication,:background)
public function updateComplication() {
  var favoriteRegionId = $.getFavoriteRegionId();

  var newComplicationValue = null;
  if (favoriteRegionId != null) {
    var forecast = $.getSimpleForecastForRegion(favoriteRegionId);

    if (forecast != null) {
      newComplicationValue = $.getDangerLevelToday(forecast[0]);
    }
  }

  if ($.Debug) {
    $.logMessage("Setting new complication value " + newComplicationValue);
  }
  try {
    if (Toybox.Complications has :updateComplication) {
      Toybox.Complications.updateComplication(0, {
        :value => newComplicationValue,
      });
    } else {
      if ($.Debug) {
        $.logMessage("updateComplication method not found on complications.");
      }
    }
  } catch (ex) {
    if ($.Debug) {
      $.logMessage(
        "Failed to update complication. Error was: " + ex.getErrorMessage()
      );
      ex.printStackTrace();
    }
  }
  if ($.Debug) {
    $.logMessage("Done update complication");
  }
}
