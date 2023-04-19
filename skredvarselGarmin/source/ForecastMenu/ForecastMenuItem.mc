import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Time;
using Toybox.Time.Gregorian;

using AvalancheUi;

public class ForecastMenuItem extends Ui.CustomMenuItem {
  public var regionId as String;
  private var _menu as ForecastMenu;
  private var _forecast as SimpleAvalancheForecast?;
  private var _dataAge as Number?;

  private var _loadingText as Ui.Resource;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;

  public function initialize(menu as ForecastMenu, regionId as String) {
    CustomMenuItem.initialize(regionId, {});

    self.regionId = regionId;
    _menu = menu;

    _loadingText = $.getOrLoadResourceString("Laster...", :Loading);

    getForecastFromCache();
    if (_forecast == null || _dataAge > $.TIME_TO_CONSIDER_DATA_STALE) {
      $.log(
        "Null or stale simple forecast for menu item, try to reload in background"
      );

      $.loadSimpleForecastForRegion(regionId, method(:onReceive), true);
    }
  }

  //! Draw the item string at the center of the item.
  //! @param dc Device context
  public function draw(dc as Gfx.Dc) as Void {
    if (_forecast != null && _dataAge < $.TIME_TO_SHOW_LOADING) {
      drawTimeline(dc);
    } else {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      dc.drawText(
        0,
        dc.getHeight() / 2,
        Graphics.FONT_GLANCE,
        _loadingText,
        Graphics.TEXT_JUSTIFY_LEFT
      );
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

      var regionName = $.getRegionName(regionId);
      var forecastTimeline = new AvalancheUi.ForecastTimeline({
        :locX => marginLeft,
        :locY => 0,
        :width => width - marginRight,
        :height => height,
        :regionName => regionName,
        :forecast => _forecast,
      });

      forecastTimeline.draw(bufferedDc);
    }

    dc.drawBitmap(0, 0, _bufferedBitmap);
  }

  private function getForecastFromCache() as Void {
    var data = $.getSimpleForecastForRegion(regionId);

    if (data != null) {
      // Reset buffered bitmap when receiving new data
      _bufferedBitmap = null;
      _forecast = data[0];
      _dataAge = $.getStorageDataAge(data);
    }
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      getForecastFromCache();
      _menu.redrawTitleAndFooter();
    }
  }
}
