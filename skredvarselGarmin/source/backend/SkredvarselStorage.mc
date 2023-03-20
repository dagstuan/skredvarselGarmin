import Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Time;
using Toybox.Time.Gregorian;

const SelectedRegionIdsStorageKey = "selectedRegionIds";

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
  var valueFromStorage = Storage.getValue($.SelectedRegionIdsStorageKey);

  return valueFromStorage != null ? valueFromStorage : new [0];
}

(:glance)
function getFavoriteRegionId() as String? {
  var favoriteRegions = $.getSelectedRegionIds();

  if (favoriteRegions != null && favoriteRegions.size() > 0) {
    return favoriteRegions[0];
  }

  return null;
}

(:background)
function resetStorageCacheIfRequired() {
  var STORAGE_VERSION = 2;
  var storageVersion = Storage.getValue("storageVersion") as Number?;

  if (storageVersion == null || storageVersion != STORAGE_VERSION) {
    $.logMessage("Wrong storage version detected. Resetting cache");
    var hasSubscription = $.getHasSubscription();
    var selectedRegionIds = $.getSelectedRegionIds();
    Storage.clearValues();
    setSelectedRegionIdsInStorage(selectedRegionIds);
    $.setHasSubscription(hasSubscription);
    Storage.setValue("storageVersion", STORAGE_VERSION);
  }
}

(:background)
function setSelectedRegionIdsInStorage(regionIds as Array<String>) {
  Storage.setValue(SelectedRegionIdsStorageKey, regionIds);
}

public function toggleFavoriteRegion(regionId as String) as Void {
  var selectedRegionIds = self.getSelectedRegionIds();

  if (selectedRegionIds != null) {
    // Remove from favorites.
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
    var newRegionIds = addToArray(selectedRegionIds, regionId);
    setSelectedRegionIdsInStorage(newRegionIds);
  }
}

function removeForecastDataForRegion(regionId as String) {
  Storage.deleteValue(getSimpleForecastCacheKeyForRegion(regionId));
  Storage.deleteValue(getDetailedWarningsCacheKeyForRegion(regionId));
}
