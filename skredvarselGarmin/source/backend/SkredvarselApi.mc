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

  public function getForecastForRegion(
    regionId as String
  ) as SimpleAvalancheForecast? {
    var fromStorage = _skredvarselStorage.getForecastDataForRegion(regionId);

    return fromStorage != null
      ? new SimpleAvalancheForecast(regionId, fromStorage)
      : null;
  }

  public function loadSimpleForecastForRegion(
    regionId as String?,
    callback as (Method(data) as Void)
  ) {
    if (regionId == null || !Regions.hasKey(regionId)) {
      throw new SkredvarselGarminException("Invalid region specified.");
    }

    if (!$.hasPhoneConnection()) {
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

    var storageKey = _skredvarselStorage.getCacheKeyForRegion(regionId);

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

    if (!$.hasPhoneConnection()) {
      $.logMessage("No connection available. Skipping loading forecast.");
      return;
    }

    var now = Time.now();

    var path =
      "/detailedWarningByRegion/" + regionId + "/1/" + getFormattedDate(now);

    // var storageKey = _skredvarselStorage.getCacheKeyForDetailedRegion(regionId);

    var delegate = new WebRequestDelegate(_queue, path, null, callback);
    delegate.makeRequest();
  }
}
