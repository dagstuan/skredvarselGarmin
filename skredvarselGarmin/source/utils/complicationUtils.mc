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

  $.log("Setting new complication value " + newComplicationValue);

  try {
    if (Toybox.Complications has :updateComplication) {
      Toybox.Complications.updateComplication(0, {
        :value => newComplicationValue,
      });
    } else {
      $.log("updateComplication method not found on complications.");
    }
  } catch (ex) {
    $.log("Failed to update complication. Error was: " + ex.getErrorMessage());
    if ($.Debug) {
      ex.printStackTrace();
    }
  }
  $.log("Done update complication");
}
