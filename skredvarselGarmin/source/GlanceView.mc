import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time.Gregorian;

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _skredvarselApi as SkredvarselApi;
  private var _regionId as String;

  private var _forecastData as AvalancheForecast?;

  function initialize(skredvarselApi as SkredvarselApi) {
    GlanceView.initialize();
    _skredvarselApi = skredvarselApi;

    _regionId = $.getFavoriteRegionId();
    setForecastDataFromStorage();
  }

  function onShow() {
    _skredvarselApi.loadForecastForRegionIfRequired(
      _regionId,
      method(:onReceive)
    );
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_forecastData == null) {
      setForecastDataFromStorage();
    }

    if (_forecastData != null) {
      var forecast = new AvalancheForecastRenderer(_regionId, _forecastData, 0);
      forecast.draw(dc);
    } else {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      dc.drawText(
        0,
        dc.getHeight() / 2,
        Graphics.FONT_GLANCE,
        "loading",
        Graphics.TEXT_JUSTIFY_LEFT
      );
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
