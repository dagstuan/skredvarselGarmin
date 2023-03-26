using Toybox.Complications;

(:background)
public function updateComplicationIfExists() {
  if ($ has :updateComplication) {
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
    Complications.updateComplication(0, {
      :value => newComplicationValue,
    });
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
