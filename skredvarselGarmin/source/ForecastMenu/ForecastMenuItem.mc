import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Time;
using Toybox.Time.Gregorian;

using AvalancheUi;

public class ForecastMenuItem extends Ui.CustomMenuItem {
  private var _regionId as String;
  private var _forecast as SimpleAvalancheForecast?;
  private var _dataAge as Number?;

  private var _screenWidth as Number;

  private var _loadingText as Ui.Resource;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;
  private var _useBufferedBitmaps as Boolean;

  private var _width as Numeric?;
  private var _height as Numeric?;

  private var _marginLeft as Numeric?;
  private var _marginRight as Numeric?;

  public function initialize(regionId as String) {
    CustomMenuItem.initialize(regionId, {});

    _regionId = regionId;
    _screenWidth = $.getDeviceScreenWidth();
    _loadingText = Ui.loadResource($.Rez.Strings.Loading);
    _useBufferedBitmaps = $.useBufferedBitmaps();

    getForecastFromCache();
    if (_forecast == null || _dataAge > $.TIME_TO_CONSIDER_DATA_STALE) {
      if ($.Debug) {
        $.logMessage(
          "Null or stale simple forecast for menu item, try to reload in background"
        );
      }

      $.loadSimpleForecastForRegion(_regionId, method(:onReceive), true);
    }
  }

  //! Draw the item string at the center of the item.
  //! @param dc Device context
  public function draw(dc as Gfx.Dc) as Void {
    if (
      _width == null ||
      _height == null ||
      _marginLeft == null ||
      _marginRight == null
    ) {
      _width = dc.getWidth();
      _height = dc.getHeight();
      _marginLeft = _width == _screenWidth ? _screenWidth * 0.05 : 0;
      _marginRight =
        _width == _screenWidth ? _screenWidth * 0.05 : _screenWidth * 0.1;
    }

    if (_forecast != null) {
      if (_useBufferedBitmaps) {
        drawTimelineBuffered(dc);
      } else {
        drawTimeline(dc);
      }
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

  function drawTimelineBuffered(dc as Gfx.Dc) {
    if (_bufferedBitmap == null) {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _width,
        :height => _height,
      });
      var bufferedDc = _bufferedBitmap.getDc();

      var forecastTimeline = new AvalancheUi.ForecastTimeline({
        :locX => _marginLeft,
        :locY => 0,
        :width => _width - _marginRight,
        :height => _height,
        :regionId => _regionId,
        :forecast => _forecast,
      });

      forecastTimeline.draw(bufferedDc);
    }

    dc.drawBitmap(0, 0, _bufferedBitmap);
  }

  function drawTimeline(dc as Gfx.Dc) {
    var forecastTimeline = new AvalancheUi.ForecastTimeline({
      :locX => _marginLeft,
      :locY => 0,
      :width => _width - _marginRight,
      :height => _height,
      :regionId => _regionId,
      :forecast => _forecast,
    });

    forecastTimeline.draw(dc);
  }

  private function getForecastFromCache() as Void {
    var data = $.getSimpleForecastForRegion(_regionId);

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
      Ui.requestUpdate();
    }
  }

  public function getRegionId() as String {
    return _regionId;
  }
}
