import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

typedef ForecastMenuItemSettings as {
  :menu as ForecastMenu,
  :regionId as String?,
  :isLocationForecast as Boolean?,
};

public class ForecastMenuItem extends Ui.CustomMenuItem {
  private var _regionId as String;
  private var _isLocationForecast as Boolean;
  private var _menu as ForecastMenu;

  private var _forecastData as SimpleForecastData?;
  private var _dataAge as Number?;

  private var _loadingText as Ui.Resource;
  private var _waitingForLocationText as Ui.Resource;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;

  public function initialize(settings as ForecastMenuItemSettings) {
    if (settings[:regionId] == null && settings[:isLocationForecast] == null) {
      throw new SkredvarselGarminException(
        "No regionId provided for non-location ForecastMenuItem."
      );
    }

    _regionId = settings[:regionId];
    _isLocationForecast = settings[:isLocationForecast];

    var menuItemId = _isLocationForecast ? "location-forecast" : _regionId;
    CustomMenuItem.initialize(menuItemId, {});

    _menu = settings[:menu];

    _loadingText = $.getOrLoadResourceString("Laster...", :Loading);
    _waitingForLocationText = $.getOrLoadResourceString(
      "Venter på posisjon...",
      :WaitingForLocation
    );

    getForecastFromCache();
    if (_forecastData == null || _dataAge > $.TIME_TO_CONSIDER_DATA_STALE) {
      if ($.Debug) {
        $.log(
          "Null or stale simple forecast for menu item, try to reload in background"
        );
      }

      if (_isLocationForecast) {
        $.loadSimpleForecastForLocation(method(:onReceive), true);
      } else {
        $.loadSimpleForecastForRegion(_regionId, method(:onReceive), true);
      }
    }
  }

  public function draw(dc as Gfx.Dc) as Void {
    if (_isLocationForecast && _forecastData == null) {
      getForecastFromCache();
    }

    if (_forecastData != null && _dataAge < $.TIME_TO_SHOW_LOADING) {
      drawTimeline(dc);
    } else {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      if (_isLocationForecast && $.getLocation() == null) {
        dc.drawText(
          0,
          dc.getHeight() / 2,
          Graphics.FONT_GLANCE,
          _waitingForLocationText,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      } else {
        dc.drawText(
          0,
          dc.getHeight() / 2,
          Graphics.FONT_GLANCE,
          _loadingText,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }
    }
  }

  function drawTimeline(dc as Gfx.Dc) {
    if (_bufferedBitmap == null) {
      var screenWidth = $.getDeviceScreenWidth();
      var width = dc.getWidth();
      var height = dc.getHeight();
      var marginLeft = width == screenWidth ? screenWidth * 0.05 : 0;
      var marginRight =
        width == screenWidth ? screenWidth * 0.05 : screenWidth * 0.1;

      _bufferedBitmap = $.newBufferedBitmap({
        :width => width,
        :height => height,
      });
      var bufferedDc = _bufferedBitmap.getDc();

      var forecast = _isLocationForecast
        ? (_forecastData as LocationAvalancheForecast)["warnings"]
        : _forecastData;

      var forecastTimeline = new AvalancheUi.ForecastTimeline({
        :locX => marginLeft,
        :locY => 0,
        :width => width - marginRight,
        :height => height,
        :regionName => $.getRegionName(getRegionId()),
        :forecast => forecast,
        :isLocationForecast => _isLocationForecast,
      });

      forecastTimeline.draw(bufferedDc);
    }

    dc.drawBitmap(0, 0, _bufferedBitmap);
  }

  private function getForecastFromCache() as Void {
    var data = _isLocationForecast
      ? $.getSimpleForecastForLocation()
      : $.getSimpleForecastForRegion(_regionId);

    if (data != null) {
      // Reset buffered bitmap when receiving new data
      _bufferedBitmap = null;
      _forecastData = data[0];
      _dataAge = $.getStorageDataAge(data);
    }
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    if (responseCode == 200) {
      getForecastFromCache();
      _menu.redrawTitleAndFooter();
    }
  }

  public function getRegionId() {
    return _isLocationForecast
      ? (_forecastData as LocationAvalancheForecast)["regionId"]
      : _regionId;
  }
}
