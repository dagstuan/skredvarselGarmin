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

  private var _avalancheForecastRenderer as AvalancheForecastRenderer;

  private var _width as Number?;
  private var _height as Number?;

  function initialize(
    skredvarselApi as SkredvarselApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    GlanceView.initialize();
    _skredvarselApi = skredvarselApi;

    _regionId = skredvarselStorage.getFavoriteRegionId();
    _avalancheForecastRenderer = new AvalancheForecastRenderer();

    setForecastDataFromStorage();
  }

  function onShow() {
    if (_regionId != null && _forecastData == null) {
      _skredvarselApi.loadForecastForRegion(_regionId, method(:onReceive));
    }
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_forecastData == null) {
      setForecastDataFromStorage();
    }

    if (_forecastData != null) {
      _avalancheForecastRenderer.setData(_regionId, _forecastData);
      _avalancheForecastRenderer.draw(dc, 0, 0, _width, _height);
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

  private function setForecastDataFromStorage() as Void {
    _forecastData = _skredvarselApi.getForecastForRegion(_regionId);
  }

  function onReceive() as Void {
    setForecastDataFromStorage();
    Ui.requestUpdate();
  }
}
