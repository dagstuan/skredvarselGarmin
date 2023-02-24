import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time.Gregorian;

using AvalancheUi;

typedef GlanceViewSettings as {
  :regionId as String,
};

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _regionId as String;

  private var _forecast as SimpleAvalancheForecast?;
  private var _bufferedBitmap as Gfx.BufferedBitmap?;
  private var _useBufferedBitmap as Boolean;

  private var _width as Number?;
  private var _height as Number?;

  private var _appNameText as Ui.Resource?;
  private var _loadingText as Ui.Resource?;

  function initialize(settings as GlanceViewSettings) {
    GlanceView.initialize();
    _regionId = settings[:regionId];
    _useBufferedBitmap = $.useBufferedBitmaps();
  }

  function onShow() {
    _appNameText = Ui.loadResource($.Rez.Strings.AppName);
    _loadingText = Ui.loadResource($.Rez.Strings.Loading);
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();

    setForecastDataFromStorage();
    if (_forecast == null) {
      $.loadSimpleForecastForRegion(_regionId, method(:onReceive));
    }
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_forecast != null) {
      if (_useBufferedBitmap) {
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

      drawTimeline(bufferedDc);
    }

    dc.drawBitmap(0, 0, _bufferedBitmap);
  }

  function drawTimeline(dc as Gfx.Dc) {
    var forecastTimeline = new AvalancheUi.ForecastTimeline({
      :locX => 0,
      :locY => 0,
      :width => _width,
      :height => _height,
      :regionId => _regionId,
      :forecast => _forecast,
    });

    forecastTimeline.draw(dc);
  }

  function onHide() {
    _appNameText = null;
    _loadingText = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = $.getSimpleForecastForRegion(_regionId);

    if (data != null) {
      _bufferedBitmap = null;
      _forecast = data[0];
    }
  }

  function onReceive(data as WebRequestCallbackData) as Void {
    setForecastDataFromStorage();
    Ui.requestUpdate();
  }
}
