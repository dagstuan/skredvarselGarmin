import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

public class WidgetView extends Ui.View {
  private var _regionId as String?;
  private var _forecast as SimpleAvalancheForecast?;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;

  private var _width as Number?;
  private var _height as Number?;

  private var _appNameText as Ui.Resource?;
  private var _loadingText as Ui.Resource?;

  public function initialize() {
    View.initialize();

    _regionId = $.getFavoriteRegionId();
    setForecastDataFromStorage();
  }

  function onShow() {
    _appNameText = Ui.loadResource($.Rez.Strings.AppName) as String;
    _loadingText = Ui.loadResource($.Rez.Strings.Loading) as String;

    if (_regionId != null && _forecast == null) {
      $.loadSimpleForecastForRegion(_regionId, method(:onReceive));
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
        0,
        dc.getHeight() / 2,
        Graphics.FONT_MEDIUM,
        _appNameText,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      if (_forecast != null) {
        var margin = 10;
        var forecastHeight = 80;
        if (_bufferedBitmap == null) {
          var forecastWidth = _width - margin * 2;

          _bufferedBitmap = $.newBufferedBitmap({
            :width => forecastWidth,
            :height => forecastHeight,
          });
          var bufferedDc = _bufferedBitmap.getDc();

          var forecastTimeline = new AvalancheUi.ForecastTimeline({
            :locX => 0,
            :locY => 0,
            :width => forecastWidth,
            :height => forecastHeight,
            :regionId => _regionId,
            :forecast => _forecast,
          });
          forecastTimeline.draw(bufferedDc);
        }

        var x0 = margin;
        var y0 = (_height * 0.55 - forecastHeight / 2).toNumber();

        dc.drawBitmap(x0, y0, _bufferedBitmap);
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

  public function onHide() {
    _appNameText = null;
    _loadingText = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = $.getSimpleForecastForRegion(_regionId);

    if (data != null) {
      _forecast = data[0];
    }
  }

  function onReceive(data as WebRequestCallbackData) as Void {
    setForecastDataFromStorage();
    Ui.requestUpdate();
  }

  function drawTitle(dc as Gfx.Dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var iconResource = getIconResourceToDraw();
    var icon = Ui.loadResource(iconResource);
    var iconX = _width / 2 - $.halfWidthDangerLevelIcon;
    dc.drawBitmap(iconX, 10, icon);

    dc.drawText(
      _width / 2,
      _height * 0.25,
      Graphics.FONT_XTINY,
      _appNameText,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setPenWidth(1);

    var marginLeftRight = 35;
    var yOffset = _height * 0.3;

    dc.drawLine(marginLeftRight, yOffset, _width - marginLeftRight, yOffset);
  }

  private function getIconResourceToDraw() as Symbol {
    var favoriteRegionId = $.getFavoriteRegionId();

    if (favoriteRegionId != null) {
      var dataForFavoriteRegion =
        $.getSimpleForecastForRegion(favoriteRegionId);

      if (dataForFavoriteRegion != null) {
        var dangerLevelToday = $.getDangerLevelToday(dataForFavoriteRegion[0]);

        return $.getIconResourceForDangerLevel(dangerLevelToday);
      }

      return $.Rez.Drawables.Level2;
    }

    return $.Rez.Drawables.Level2;
  }
}
