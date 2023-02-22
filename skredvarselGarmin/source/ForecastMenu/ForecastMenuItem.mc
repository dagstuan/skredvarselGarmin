import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;

using AvalancheUi;

public class ForecastMenuItem extends Ui.CustomMenuItem {
  private var _regionId as String;
  private var _forecast as SimpleAvalancheForecast?;
  private var _simpleForecastApi as SimpleForecastApi;

  private var _redrawForecast as Boolean = false;

  private var _screenWidth as Number;

  private var _loadingText as Ui.Resource;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;

  private var _width as Numeric?;
  private var _height as Numeric?;

  public function initialize(
    simpleForecastApi as SimpleForecastApi,
    regionId as String
  ) {
    CustomMenuItem.initialize(regionId, {});

    _simpleForecastApi = simpleForecastApi;
    _regionId = regionId;

    _screenWidth = $.getDeviceScreenWidth();

    _loadingText = Ui.loadResource($.Rez.Strings.Loading);

    getForecastFromCache();
    if (_forecast == null) {
      _simpleForecastApi.loadSimpleForecastForRegion(
        _regionId,
        method(:onReceive)
      );
    }
  }

  //! Draw the item string at the center of the item.
  //! @param dc Device context
  public function draw(dc as Gfx.Dc) as Void {
    if (_width == null || _height == null) {
      _width = dc.getWidth();
      _height = dc.getHeight();
    }

    if (_forecast != null) {
      if (_bufferedBitmap == null) {
        var marginLeft = _width == _screenWidth ? 10 : 0;
        var marginRight = _width == _screenWidth ? 10 : 25;

        _bufferedBitmap = $.newBufferedBitmap({
          :width => _width,
          :height => _height,
        });
        var bufferedDc = _bufferedBitmap.getDc();

        var forecastTimeline = new AvalancheUi.ForecastTimeline({
          :locX => marginLeft,
          :locY => 0,
          :width => _width - marginRight,
          :height => _height,
          :regionId => _regionId,
          :forecast => _forecast,
        });

        forecastTimeline.draw(bufferedDc);
      }

      dc.drawBitmap(0, 0, _bufferedBitmap);
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

  private function getForecastFromCache() as Void {
    var forecastArray =
      _simpleForecastApi.getSimpleForecastForRegion(_regionId);

    if (forecastArray != null) {
      // Reset buffered bitmap when receiving new data
      _bufferedBitmap = null;
      _forecast = forecastArray[0];
    }
  }

  public function onReceive(data as WebRequestCallbackData) as Void {
    getForecastFromCache();
    Ui.requestUpdate();
  }

  public function getRegionId() as String {
    return _regionId;
  }
}
