import Toybox.Lang;

using Toybox.Application.Storage;

(:background)
function getSimpleForecastCacheKeyForRegion(regionId as String) {
  return "simple_" + regionId;
}

(:background)
function getDetailedWarningsCacheKeyForRegion(regionId as String) {
  return "detailed_" + regionId;
}

(:background)
function getSelectedRegionIds() as Array<String> {
  var valueFromStorage =
    Storage.getValue("selectedRegionIds") as Array<String>?;

  return valueFromStorage != null ? valueFromStorage : new [0];
}

(:background)
function setSelectedRegionIdsInStorage(regionIds as Array<String>) {
  Storage.setValue("selectedRegionIds", regionIds);
}

(:background)
function getFavoriteRegionId() as String? {
  var favoriteRegions = $.getSelectedRegionIds();

  if (favoriteRegions.size() > 0) {
    return favoriteRegions[0];
  }

  return null;
}

(:background)
function resetStorageCacheIfRequired() {
  var STORAGE_VERSION = 3;
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
    var selectedRegionIds = $.getSelectedRegionIds();
    try {
      Storage.clearValues();
    } catch (ex) {
      if ($.Debug) {
        $.log("Failed to reset storage cache.");
        ex.printStackTrace();
      }
      throw ex;
    }
    setSelectedRegionIdsInStorage(selectedRegionIds);
    $.setHasSubscription(hasSubscription);
    Storage.setValue("storageVersion", STORAGE_VERSION);
    Storage.setValue("cachedStorageLanguage", forecastLanguageSetting);
  }
}

public function toggleFavoriteRegion(regionId as String) as Void {
  var selectedRegionIds = self.getSelectedRegionIds();

  var regionIdsSize = selectedRegionIds.size();

  if (regionId.equals(selectedRegionIds[0])) {
    selectedRegionIds[0] = selectedRegionIds[1];
    selectedRegionIds[1] = regionId;
  } else {
    // Set as favorite.
    // Move element to beginning, shifting other elements.
    var index = -1;
    for (var i = 0; i < regionIdsSize; i++) {
      if (selectedRegionIds[i].equals(regionId)) {
        index = i;
        break;
      }
    }

    for (var i = index; i > 0; i--) {
      selectedRegionIds[i] = selectedRegionIds[i - 1];
    }

    selectedRegionIds[0] = regionId;
  }

  setSelectedRegionIdsInStorage(selectedRegionIds);
}

public function removeSelectedRegion(regionId as String) {
  var selectedRegionIds = getSelectedRegionIds();

  if (arrayContainsString(selectedRegionIds, regionId)) {
    var newRegionIds = removeStringFromArray(selectedRegionIds, regionId);
    setSelectedRegionIdsInStorage(newRegionIds);
    removeForecastDataForRegion(regionId);
  }
}

public function addSelectedRegion(regionId as String) {
  var selectedRegionIds = getSelectedRegionIds();

  if (!arrayContainsString(selectedRegionIds, regionId)) {
    var newRegionIds = selectedRegionIds.add(regionId);
    setSelectedRegionIdsInStorage(newRegionIds);
  }
}

function removeForecastDataForRegion(regionId as String) {
  Storage.deleteValue(getSimpleForecastCacheKeyForRegion(regionId));
  Storage.deleteValue(getDetailedWarningsCacheKeyForRegion(regionId));
}
