import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

public class WidgetView extends Ui.View {
  private var _regionId as String?;
  private var _forecastData as SimpleForecastData?;
  private var _dataAge as Number?;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;

  private var _width as Number?;
  private var _height as Number?;

  private var _appNameText as Ui.Resource?;
  private var _noRegionsSelectedText as Ui.Resource?;
  private var _loadingText as Ui.Resource?;

  private const _margin = 10;
  private const _forecastHeight = 80;

  private var _useLocation as Boolean = false;

  public function initialize() {
    View.initialize();
  }

  function onShow() {
    _regionId = $.getFavoriteRegionId();
    _appNameText = $.getOrLoadResourceString("Skredvarsel", :AppName);
    _useLocation = $.getUseLocation();
    _noRegionsSelectedText = $.getOrLoadResourceString(
      "Ingen regioner valgt.",
      :NoRegionsSelected
    );
    _loadingText = $.getOrLoadResourceString("Laster...", :Loading);

    setForecastDataFromStorage();
    if (
      (_regionId != null || _useLocation) &&
      (_forecastData == null || _dataAge > $.TIME_TO_CONSIDER_DATA_STALE)
    ) {
      $.log(
        "Null or stale simple forecast for widget, try to reload in background"
      );

      if (_useLocation) {
        $.loadSimpleForecastForLocation(method(:onReceive), false);
      } else {
        $.loadSimpleForecastForRegion(_regionId, method(:onReceive), false);
      }
    }
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    drawTitle(dc);

    if (_regionId == null) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      dc.drawText(
        dc.getWidth() / 2,
        dc.getHeight() / 2,
        Graphics.FONT_SMALL,
        _noRegionsSelectedText,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      if (_forecastData != null) {
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
  }

  function drawTimeline(dc as Gfx.Dc) {
    if (_bufferedBitmap == null) {
      var forecastWidth = _width - _margin * 2;

      _bufferedBitmap = $.newBufferedBitmap({
        :width => forecastWidth,
        :height => _forecastHeight,
      });
      var bufferedDc = _bufferedBitmap.getDc();

      var regionId = _useLocation
        ? (_forecastData as LocationAvalancheForecast)["regionId"]
        : _regionId;

      var forecast = _useLocation
        ? (_forecastData as LocationAvalancheForecast)["warnings"]
        : _forecastData;

      var forecastTimeline = new AvalancheUi.ForecastTimeline({
        :locX => 0,
        :locY => 0,
        :width => forecastWidth,
        :height => _forecastHeight,
        :regionName => $.getRegionName(regionId),
        :forecast => forecast,
        :isLocationForecast => _useLocation,
      });
      forecastTimeline.draw(bufferedDc);
    }

    var x0 = _margin;
    var y0 = (_height * 0.55 - _forecastHeight / 2).toNumber();

    dc.drawBitmap(x0, y0, _bufferedBitmap);
  }

  public function onHide() {
    _appNameText = null;
    _noRegionsSelectedText = null;
    _loadingText = null;
    _bufferedBitmap = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = _useLocation
      ? $.getSimpleForecastForLocation()
      : $.getSimpleForecastForRegion(_regionId);

    if (data != null) {
      _forecastData = data[0];
      _dataAge = $.getStorageDataAge(data);
    }
  }

  function onReceive(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    if (responseCode == 200) {
      setForecastDataFromStorage();
      Ui.requestUpdate();
    }
  }

  function drawTitle(dc as Gfx.Dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var iconResource = $.getIconResourceForForecastMenu();
    var icon = Ui.loadResource(iconResource);
    var iconX = _width / 2 - $.getHalfWidthDangerLevelIcon();
    dc.drawBitmap(iconX, 10, icon);

    dc.drawText(
      _width / 2,
      _height * 0.25,
      Graphics.FONT_XTINY,
      _appNameText,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(1);

    var marginLeftRight = 35;
    var yOffset = _height * 0.33;

    dc.drawLine(marginLeftRight, yOffset, _width - marginLeftRight, yOffset);
  }
}
