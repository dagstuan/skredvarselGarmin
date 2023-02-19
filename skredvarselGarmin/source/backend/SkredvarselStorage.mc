import Toybox.Lang;

using Toybox.Application.Storage;
using Toybox.Time;
using Toybox.Time.Gregorian;

const SelectedRegionIdsStorageKey = "selectedRegionIds";

(:background)
public class SkredvarselStorage {
  public static function getSimpleForecastCacheKeyForRegion(
    regionId as String
  ) {
    return "WebRequestCache_warning_for_region_" + regionId;
  }

  public static function getDetailedWarningCacheKeyForRegion(
    regionId as String
  ) {
    return "WebRequestCache_detailed_warning_for_region_" + regionId;
  }

  public function getSelectedRegionIds() as Array<String> {
    var valueFromStorage = Storage.getValue($.SelectedRegionIdsStorageKey);

    return valueFromStorage != null ? valueFromStorage : new [0];
  }

  public function getFavoriteRegionId() as String? {
    var favoriteRegions = getSelectedRegionIds();

    if (favoriteRegions != null && favoriteRegions.size() > 0) {
      return favoriteRegions[0];
    }

    return null;
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

  public function addSelectedRegion(regionId as String) {
    var selectedRegionIds = getSelectedRegionIds();

    if (!arrayContainsString(selectedRegionIds, regionId)) {
      var newRegionIds = addToArray(selectedRegionIds, regionId);
      setSelectedRegionIdsInStorage(newRegionIds);
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

  public function getSimpleForecastDataForRegion(regionId as String) as Array? {
    var cacheKey = getSimpleForecastCacheKeyForRegion(regionId);

    return getFromStorage(cacheKey);
  }

  public function getDetailedWarningDataForRegion(
    regionId as String
  ) as Array? {
    var cacheKey = getDetailedWarningCacheKeyForRegion(regionId);

    return getFromStorage(cacheKey);
  }

  private function getFromStorage(storageKey as String) {
    var value = Storage.getValue(storageKey);

    if (
      value != null &&
      value instanceof Array &&
      value.size() == 2 &&
      value[1] instanceof Number
    ) {
      return value;
    }

    return null;
  }

  private function removeForecastDataForRegion(regionId as String) {
    Storage.deleteValue(getSimpleForecastCacheKeyForRegion(regionId));
    Storage.deleteValue(getDetailedWarningCacheKeyForRegion(regionId));
  }

  private function setSelectedRegionIdsInStorage(regionIds as Array<String>) {
    Storage.setValue(SelectedRegionIdsStorageKey, regionIds);
  }
}
