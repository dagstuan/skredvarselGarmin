import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

using AvalancheUi;

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _hasSubscription as Boolean?;
  private var _favoriteRegionId as String?;

  private var _forecast as SimpleAvalancheForecast?;
  private var _dataAge as Number?;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;
  private var _useBufferedBitmap as Boolean;

  private var _width as Number?;
  private var _height as Number?;

  private var _appNameText as Ui.Resource?;

  function initialize() {
    GlanceView.initialize();
    _useBufferedBitmap = $.useBufferedBitmaps();
  }

  function onShow() {
    _hasSubscription = $.getHasSubscription();
    _favoriteRegionId = $.getFavoriteRegionId();
    _appNameText = $.getOrLoadResourceString("Skredvarsel", :AppName);
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_hasSubscription && _favoriteRegionId != null && _forecast == null) {
      setForecastDataFromStorage();
    }

    if (
      _hasSubscription == false ||
      _favoriteRegionId == null ||
      _forecast == null ||
      _dataAge > $.TIME_TO_SHOW_LOADING
    ) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        0,
        _height / 2,
        Gfx.FONT_GLANCE,
        _appNameText,
        Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
      );
      return;
    }

    if (_useBufferedBitmap) {
      drawTimelineBuffered(dc);
    } else {
      drawTimeline(dc);
    }
  }

  function drawTimelineBuffered(dc as Gfx.Dc) {
    if (_bufferedBitmap == null) {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _width,
        :height => _height,
      });
      var bufferedDc = _bufferedBitmap.getDc();

      drawTimeline(bufferedDc);
    }

    dc.drawBitmap(0, 0, _bufferedBitmap);
  }

  function drawTimeline(dc as Gfx.Dc) {
    var regionName = $.getRegionName(_favoriteRegionId);

    var forecastTimeline = new AvalancheUi.ForecastTimeline({
      :locX => 0,
      :locY => 0,
      :width => _width,
      :height => _height,
      :regionName => regionName,
      :forecast => _forecast,
    });

    forecastTimeline.draw(dc);
  }

  function onHide() {
    _appNameText = null;
    _bufferedBitmap = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = $.getSimpleForecastForRegion(_favoriteRegionId);

    if (data != null) {
      _bufferedBitmap = null;
      _forecast = data[0];
      _dataAge = $.getStorageDataAge(data);
    }
  }
}
