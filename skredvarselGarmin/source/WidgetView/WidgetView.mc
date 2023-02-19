import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

public class WidgetView extends Ui.View {
  private var _regionId as String?;
  private var _forecastData as SimpleAvalancheForecast?;

  private var _skredvarselApi as SkredvarselApi;
  private var _skredvarselStorage as SkredvarselStorage;

  private var _forecastTimeline as AvalancheUi.ForecastTimeline?;

  private var _width as Number?;
  private var _height as Number?;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    View.initialize();

    _skredvarselApi = skredvarselApi;
    _skredvarselStorage = skredvarselStorage;

    _regionId = skredvarselStorage.getFavoriteRegionId();
    setForecastDataFromStorage();
  }

  function onShow() {
    if (_regionId != null && _forecastData == null) {
      _skredvarselApi.loadSimpleForecastForRegion(
        _regionId,
        method(:onReceive)
      );
    }
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();

    var margin = 10;

    var forecastWidth = _width - margin;
    var forecastHeight = 80;
    var x0 = margin;
    var y0 = (_height * 0.55 - forecastHeight / 2).toNumber();

    _forecastTimeline = new AvalancheUi.ForecastTimeline();
    _forecastTimeline.setSettings({
      :locX => x0,
      :locY => y0,
      :width => forecastWidth,
      :height => forecastHeight,
    });
  }

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    drawTitle(dc);

    if (_regionId == null) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      var appNameText = Ui.loadResource($.Rez.Strings.AppName) as String;

      dc.drawText(
        0,
        dc.getHeight() / 2,
        Graphics.FONT_MEDIUM,
        appNameText,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      if (_forecastData == null) {
        setForecastDataFromStorage();
      }

      if (_forecastData != null) {
        _forecastTimeline.setData(_regionId, _forecastData);
        _forecastTimeline.draw(dc);
      } else {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        var loadingText = Ui.loadResource($.Rez.Strings.Loading) as String;

        dc.drawText(
          0,
          dc.getHeight() / 2,
          Graphics.FONT_GLANCE,
          loadingText,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }
    }
  }

  private function setForecastDataFromStorage() as Void {
    _forecastData = _skredvarselApi.getSimpleForecastForRegion(_regionId);
  }

  function onReceive(data) as Void {
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

    var text = Ui.loadResource($.Rez.Strings.AppName);
    dc.drawText(
      _width / 2,
      _height * 0.25,
      Graphics.FONT_XTINY,
      text,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setPenWidth(1);

    var marginLeftRight = 35;
    var yOffset = _height * 0.3;

    dc.drawLine(marginLeftRight, yOffset, _width - marginLeftRight, yOffset);
  }

  private function getIconResourceToDraw() as Symbol {
    var favoriteRegionId = _skredvarselStorage.getFavoriteRegionId();

    if (favoriteRegionId != null) {
      var forecastForFavoriteRegion =
        _skredvarselApi.getSimpleForecastForRegion(favoriteRegionId);

      if (forecastForFavoriteRegion != null) {
        var dangerLevelToday = forecastForFavoriteRegion.getDangerLevelToday();

        return $.getIconResourceForDangerLevel(dangerLevelToday);
      }

      return $.Rez.Drawables.LauncherIcon;
    }

    return $.Rez.Drawables.LauncherIcon;
  }
}
