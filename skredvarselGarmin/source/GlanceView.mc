import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time.Gregorian;

using AvalancheUi;

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _skredvarselApi as SkredvarselApi;
  private var _regionId as String?;

  private var _forecastData as SimpleAvalancheForecast?;

  private var _forecastTimeline as AvalancheUi.ForecastTimeline?;

  private var _width as Number?;
  private var _height as Number?;

  private var _appNameText as Ui.Resource?;
  private var _loadingText as Ui.Resource?;

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
    if (_regionId != null && _forecastData == null) {
      _skredvarselApi.loadSimpleForecastForRegion(
        _regionId,
        method(:onReceive)
      );
    }

    _appNameText = Ui.loadResource($.Rez.Strings.AppName);
    _loadingText = Ui.loadResource($.Rez.Strings.Loading);
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();

    _forecastTimeline = new AvalancheUi.ForecastTimeline();
    _forecastTimeline.setSettings({
      :locX => 0,
      :locY => 0,
      :width => _width,
      :height => _height,
    });
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_regionId == null) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      dc.drawText(
        0,
        _height / 2,
        Graphics.FONT_GLANCE,
        _appNameText,
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

  function onHide() {
    _appNameText = null;
    _loadingText = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = _skredvarselApi.getSimpleForecastForRegion(_regionId);

    if (data != null) {
      _forecastData = new SimpleAvalancheForecast(_regionId, data[0]);
    }
  }

  function onReceive(data) as Void {
    setForecastDataFromStorage();
    Ui.requestUpdate();
  }
}
