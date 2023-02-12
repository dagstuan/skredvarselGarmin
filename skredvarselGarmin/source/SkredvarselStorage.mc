import Toybox.Lang;

using Toybox.Application.Storage;

const SelectedRegionIdsStorageKey = "selectedRegionIds";
const FavoriteRegionIdStorageKey = "favoriteRegion";

(:background)
class SkredvarselStorage {
  static function addSelectedRegion(regionId as String) {
    var selectedRegionIds = SkredvarselStorage.getSelectedRegionIds();

    if (!arrayContainsString(selectedRegionIds, regionId)) {
      var newRegionIds = addToArray(selectedRegionIds, regionId);
      setSelectedRegionIdsInStorage(newRegionIds);
    }
  }

  static function removeSelectedRegion(regionId as String) {
    var selectedRegionIds = SkredvarselStorage.getSelectedRegionIds();

    if (arrayContainsString(selectedRegionIds, regionId)) {
      var newRegionIds = removeStringFromArray(selectedRegionIds, regionId);
      setSelectedRegionIdsInStorage(newRegionIds);
    }
  }

  public static function getSelectedRegionIds() as Array<String> {
    var valueFromStorage = Storage.getValue(SelectedRegionIdsStorageKey);

    if (valueFromStorage == null) {
      return new [0];
    }

    return valueFromStorage;
  }

  private static function setSelectedRegionIdsInStorage(
    regionIds as Array<String>
  ) {
    Storage.setValue(SelectedRegionIdsStorageKey, regionIds);
  }
}
