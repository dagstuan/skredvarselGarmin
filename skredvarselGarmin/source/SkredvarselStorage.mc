import Toybox.Lang;

using Toybox.Application.Storage;

const SelectedRegionIdsStorageKey = "selectedRegionIds";

(:background)
public class SkredvarselStorage {
  private static function getCacheKeyForRegion(regionId as String) {
    return "WebRequestCache_warning_for_region_" + regionId;
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

  public function getForecastDataForRegion(
    regionId as String
  ) as AvalancheForecastData? {
    var cacheKey = getCacheKeyForRegion(regionId);

    var value = Storage.getValue(cacheKey) as AvalancheForecastData?;
    return value;
  }

  public function setForecastDataForRegion(
    regionId as String,
    data as AvalancheForecastData
  ) {
    var cacheKey = getCacheKeyForRegion(regionId);

    Storage.setValue(cacheKey, data);
  }

  private function removeForecastDataForRegion(regionId as String) {
    var cacheKey = getCacheKeyForRegion(regionId);

    Storage.deleteValue(cacheKey);
  }

  private function setSelectedRegionIdsInStorage(regionIds as Array<String>) {
    Storage.setValue(SelectedRegionIdsStorageKey, regionIds);
  }
}
