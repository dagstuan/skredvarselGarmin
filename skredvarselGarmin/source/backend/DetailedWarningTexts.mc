import Toybox.Lang;

using Toybox.Application.Storage;

// Snowpack history and mountain weather are stored under their own key per
// day instead of inside the detailed forecasts. Storing a whole Swedish
// forecast with the texts as one value needs more memory than the background
// process has on 64 KB devices, while storing a day at a time does not.
//
// WebRequestDelegate.storeTexts replaces the stored texts every time a
// detailed forecast is received, and removeForecastDataForRegion deletes them
// with the forecast.
//
// Devices with limited background memory don't fetch or show the texts at
// all.

// More than the number of days in any forecast (six for Swedish regions), so
// all texts are deleted.
const MAX_DETAILED_WARNING_TEXTS = 10;

(:background,:noLimitedBackgroundMemory)
function getDetailedWarningTextsKey(
  storageKey as String,
  index as Number
) as String {
  return storageKey + "_texts_" + index;
}

(:background,:noLimitedBackgroundMemory)
function deleteDetailedWarningTexts(storageKey as String) as Void {
  for (var i = 0; i < $.MAX_DETAILED_WARNING_TEXTS; i++) {
    Storage.deleteValue($.getDetailedWarningTextsKey(storageKey, i));
  }
}

// Called when removing a region on all devices.
(:background,:limitedBackgroundMemory)
function deleteDetailedWarningTexts(storageKey as String) as Void {}

// Removes the texts from each warning, so the forecast can be stored without
// them. Returns them per day as [validity end, snowpack history, mountain
// weather], or null for days without texts. The validity end identifies the
// day, in case the stored forecast and texts get out of sync.
(:background,:noLimitedBackgroundMemory)
function removeDetailedWarningTexts(warnings as Array) as Array {
  var texts = new [warnings.size()];
  for (var i = 0; i < warnings.size(); i++) {
    var warning = warnings[i];
    if (
      warning instanceof Dictionary &&
      warning.hasKey("mountainWeather")
    ) {
      texts[i] = [
        (warning["validity"] as Array)[1],
        warning["snowpackHistory"],
        warning["mountainWeather"],
      ];
      warning.remove("snowpackHistory");
      warning.remove("mountainWeather");
    }
  }
  return texts;
}

// Replaces the stored texts of a detailed forecast with texts, as returned by
// removeDetailedWarningTexts. Texts from an earlier forecast never remain,
// even for days without texts.
(:background,:noLimitedBackgroundMemory)
function storeDetailedWarningTexts(
  storageKey as String,
  texts as Array
) as Void {
  $.deleteDetailedWarningTexts(storageKey);
  for (var i = 0; i < texts.size(); i++) {
    if (texts[i] != null) {
      Storage.setValue(
        $.getDetailedWarningTextsKey(storageKey, i),
        texts[i]
      );
    }
  }
}

// [snowpackHistory, mountainWeather] for the warning at index, or null if
// they are missing or were stored for another day.
(:noLimitedBackgroundMemory)
function getDetailedWarningTexts(
  regionId as String,
  warnings as Array<DetailedAvalancheWarning>,
  index as Number
) as [String?, String?]? {
  var texts =
    Storage.getValue(
      $.getDetailedWarningTextsKey(
        $.getDetailedWarningsCacheKeyForRegion(regionId),
        index
      )
    ) as Array?;

  if (
    texts == null ||
    !(texts[0] as String).equals(
      (warnings[index]["validity"] as Array)[1] as String
    )
  ) {
    return null;
  }

  return [texts[1] as String?, texts[2] as String?];
}
