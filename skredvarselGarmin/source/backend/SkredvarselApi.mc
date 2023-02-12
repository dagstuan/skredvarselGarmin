import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;

(:background)
public class SkredvarselApi {
  hidden var _queue;

  public function initialize() {
    _queue = new CommandExecutor();
  }

  public function getForecastForRegion(
    regionId as String
  ) as AvalancheForecast? {
    var cacheKey = $.getCacheKeyForRegion(regionId);

    var fromStorage = Storage.getValue(cacheKey) as AvalancheForecastData?;

    return fromStorage != null
      ? new AvalancheForecast(regionId, fromStorage)
      : null;
  }

  public function loadForecastForRegionIfRequired(
    regionId as String,
    callback as (Method() as Void)
  ) {
    var warningFromStorage = getForecastForRegion(regionId);

    if (warningFromStorage == null) {
      loadForecastForRegion(regionId, callback);
    }
  }

  public function loadForecastForRegion(
    regionId as String?,
    callback as (Method() as Void)
  ) {
    if (regionId == null || !Regions.hasKey(regionId)) {
      throw new SkredvarselGarminException("Invalid region specified.");
    }

    var delegate = new GetAvalancheForecastRequestDelegate(
      _queue,
      regionId,
      callback
    );
    delegate.makeRequest();
  }
}
