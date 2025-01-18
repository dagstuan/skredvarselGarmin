import Toybox.Lang;

(:background)
public function updateComplicationIfExists() {
  if ($ has :updateSkredvarselComplication && Toybox has :Complications) {
    $.updateSkredvarselComplication();
  }
}

(:hasComplication,:background)
public function updateSkredvarselComplication() {
  var favoriteRegionId = $.getFavoriteRegionId();

  var newComplicationValue = null;
  if (favoriteRegionId != null) {
    var forecast = $.getSimpleForecastForRegion(favoriteRegionId);

    if (forecast != null) {
      newComplicationValue = $.getDangerLevelToday(forecast[0]);
    }
  }

  $.log(
    Lang.format("Setting new complication value $1$", [newComplicationValue])
  );

  try {
    if (Toybox.Complications has :updateComplication) {
      Toybox.Complications.updateComplication(0, {
        :value => newComplicationValue,
      });
    } else if ($.Debug) {
      $.log("updateComplication method not found on complications.");
    }
  } catch (ex) {
    if ($.Debug) {
      $.log(
        Lang.format("Failed to update complication. Error was: $1$", [
          ex.getErrorMessage(),
        ])
      );
      ex.printStackTrace();
    }
  }
  if ($.Debug) {
    $.log("Done update complication");
  }
}
