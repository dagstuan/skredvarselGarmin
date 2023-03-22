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
  private var _loadingText as Ui.Resource?;

  function initialize() {
    GlanceView.initialize();
    _useBufferedBitmap = $.useBufferedBitmaps();
  }

  function onShow() {
    _hasSubscription = $.getHasSubscription();
    _favoriteRegionId = $.getFavoriteRegionId();
    _appNameText = Ui.loadResource($.Rez.Strings.AppName);
    _loadingText = Ui.loadResource($.Rez.Strings.Loading);

    if (_hasSubscription && _favoriteRegionId != null) {
      setForecastDataFromStorage();
      if (
        _hasSubscription &&
        (_forecast == null || _dataAge > $.TIME_TO_CONSIDER_DATA_STALE)
      ) {
        if ($.Debug) {
          $.logMessage(
            "Null or stale simple forecast for glance, try to reload in background"
          );
        }

        $.loadSimpleForecastForRegion(
          _favoriteRegionId,
          method(:onReceive),
          false
        );
      }
    }
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_hasSubscription == false || _favoriteRegionId == null) {
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

    if (_forecast != null && _dataAge < $.TIME_TO_SHOW_LOADING) {
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
    _loadingText = null;
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

  function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200) {
      setForecastDataFromStorage();
      Ui.requestUpdate();
    }
  }
}
