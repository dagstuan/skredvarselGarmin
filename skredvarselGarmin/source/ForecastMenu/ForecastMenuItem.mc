import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;

using AvalancheUi;

public class ForecastMenuItem extends Ui.CustomMenuItem {
  private var _regionId as String;
  private var _skredvarselApi as SkredvarselApi;

  private var _hasForecast as Boolean = false;

  private var _avalancheForecastTimeline as AvalancheUi.ForecastTimeline;

  private var _screenWidth as Number;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    regionId as String
  ) {
    CustomMenuItem.initialize(regionId, {});

    _skredvarselApi = skredvarselApi;
    _regionId = regionId;
    _avalancheForecastTimeline = new AvalancheUi.ForecastTimeline();

    _screenWidth = $.getDeviceScreenWidth();

    getForecastFromCache();
    if (!_hasForecast) {
      _skredvarselApi.loadSimpleForecastForRegion(
        _regionId,
        method(:onReceive)
      );
    }
  }

  //! Draw the item string at the center of the item.
  //! @param dc Device context
  public function draw(dc as Gfx.Dc) as Void {
    if (!_hasForecast) {
      getForecastFromCache();
    }

    var width = dc.getWidth();
    var height = dc.getHeight();

    if (_hasForecast) {
      var marginLeft = width == _screenWidth ? 10 : 0;
      var marginRight = width == _screenWidth ? 10 : 25;
      _avalancheForecastTimeline.draw(
        dc,
        marginLeft,
        0,
        width - marginRight,
        height
      );
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

  private function getForecastFromCache() as Void {
    var forecast = _skredvarselApi.getForecastForRegion(_regionId);

    if (forecast != null) {
      _avalancheForecastTimeline.setData(_regionId, forecast);
      _hasForecast = true;
    }
  }

  public function onReceive(data) as Void {
    getForecastFromCache();
    Ui.requestUpdate();
  }

  public function getRegionId() as String {
    return _regionId;
  }
}
