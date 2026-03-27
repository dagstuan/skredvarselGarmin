import Toybox.Lang;

using Toybox.Application.Storage;

(:background)
function resetStorageCacheIfRequired() {
  var STORAGE_VERSION = 1;
  var storageVersion = Storage.getValue("storageVersion") as Number?;
  var cachedForecastsLanguage =
    Storage.getValue("cachedStorageLanguage") as Number?;

  var forecastLanguageSetting = $.getForecastLanguage();

  if (
    storageVersion != STORAGE_VERSION ||
    cachedForecastsLanguage != forecastLanguageSetting
  ) {
    if ($.Debug) {
      $.log(
        Lang.format("Resetting storage cache. storageVersion in Storage: $1$", [
          storageVersion,
        ])
      );
    }

    var hasSubscription = $.getHasSubscription();
    try {
      Storage.clearValues();
    } catch (ex) {
      if ($.Debug) {
        $.log("Failed to reset storage cache.");
        ex.printStackTrace();
      }
      throw ex;
    }
    $.setHasSubscription(hasSubscription);
    Storage.setValue("storageVersion", STORAGE_VERSION);
    Storage.setValue("cachedStorageLanguage", forecastLanguageSetting);
  }
}
