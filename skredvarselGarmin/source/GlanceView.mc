import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time.Gregorian;

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _skredvarselApi as SkredvarselApi;
  private var _regionId as String?;

  private var _forecastData as AvalancheForecast?;

  function initialize(
    skredvarselApi as SkredvarselApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    GlanceView.initialize();
    _skredvarselApi = skredvarselApi;

    _regionId = skredvarselStorage.getFavoriteRegionId();
    setForecastDataFromStorage();
  }

  function onShow() {
    if (_regionId != null) {
      _skredvarselApi.loadForecastForRegionIfRequired(
        _regionId,
        method(:onReceive)
      );
    }
  }

  function onUpdate(dc as Gfx.Dc) {
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
        var forecast = new AvalancheForecastRenderer(
          _regionId,
          _forecastData,
          0
        );
        forecast.draw(dc);
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
    _forecastData = _skredvarselApi.getForecastForRegion(_regionId);
  }

  function onReceive() as Void {
    setForecastDataFromStorage();
    Ui.requestUpdate();
  }
}
