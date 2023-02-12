import Toybox.Lang;
using Toybox.Application.Storage;

(:background)
function getCacheKeyForRegion(regionId as String) {
  return "WebRequestCache_warning_for_region_" + regionId;
}

(:background)
function getLoadingCacheKey(regionId as String) {
  return "WebRequestCache_loading_region_" + regionId;
}

(:background)
public function getSelectedRegionIds() as Array<String> {
  var valueFromStorage = Storage.getValue($.SelectedRegionIdsStorageKey);

  return valueFromStorage != null ? valueFromStorage : new [0];
}

(:background)
public function getFavoriteRegionId() as String? {
  return Storage.getValue($.FavoriteRegionIdStorageKey);
}
