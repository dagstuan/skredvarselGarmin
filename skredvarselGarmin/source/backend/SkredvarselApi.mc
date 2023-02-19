import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

(:background)
public class SkredvarselApi {
  hidden var _skredvarselStorage as SkredvarselStorage;
  hidden var _queue;

  public function initialize(skredvarselStorage as SkredvarselStorage) {
    _queue = new CommandExecutor();
    _skredvarselStorage = skredvarselStorage;
  }

  public function getSimpleForecastForRegion(regionId as String) as Array? {
    return _skredvarselStorage.getSimpleForecastDataForRegion(regionId);
  }

  public function getDetailedWarningForRegion(regionId as String) as Array? {
    return _skredvarselStorage.getDetailedWarningDataForRegion(regionId);
  }

  public function loadSimpleForecastForRegion(
    regionId as String?,
    callback as (Method(data) as Void)
  ) {
    if (regionId == null || !Regions.hasKey(regionId)) {
      throw new SkredvarselGarminException("Invalid region specified.");
    }

    if ($.canMakeWebRequest() == false) {
      $.logMessage("No connection available. Skipping loading forecast.");
      return;
    }

    var now = Time.now();
    var twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);
    var start = now.subtract(twoDays);
    var end = now.add(twoDays);

    var path =
      "/simpleWarningsByRegion/" +
      regionId +
      "/1/" +
      getFormattedDate(start) +
      "/" +
      getFormattedDate(end);

    var storageKey =
      _skredvarselStorage.getSimpleForecastCacheKeyForRegion(regionId);

    var delegate = new WebRequestDelegate(_queue, path, storageKey, callback);
    delegate.makeRequest();
  }

  public function loadDetailedWarningForRegion(
    regionId as String?,
    callback as (Method(data) as Void)
  ) {
    if (regionId == null || !Regions.hasKey(regionId)) {
      throw new SkredvarselGarminException("Invalid region specified.");
    }

    if ($.canMakeWebRequest() == false) {
      $.logMessage("No connection available. Skipping loading forecast.");
      return;
    }

    var now = Time.now();

    var path =
      "/detailedWarningByRegion/" + regionId + "/1/" + getFormattedDate(now);

    var storageKey =
      _skredvarselStorage.getDetailedWarningCacheKeyForRegion(regionId);

    var delegate = new WebRequestDelegate(_queue, path, storageKey, callback);
    delegate.makeRequest();
  }
}
