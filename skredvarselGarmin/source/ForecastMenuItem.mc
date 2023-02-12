import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastMenuItem extends Ui.CustomMenuItem {
  private var _regionId as String?;
  private var _skredvarselApi;

  private var _forecastData as AvalancheForecast?;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    regionId as String,
    id as String
  ) {
    CustomMenuItem.initialize(id, {});

    _skredvarselApi = skredvarselApi;
    _regionId = regionId;

    _skredvarselApi.loadForecastForRegionIfRequired(
      _regionId,
      method(:onReceive)
    );
    updateForecastData();
  }

  //! Draw the item string at the center of the item.
  //! @param dc Device context
  public function draw(dc) as Void {
    if (_forecastData == null) {
      updateForecastData();
    }

    var marginRight = 25;

    if (_forecastData != null) {
      var avalancheForecast = new AvalancheForecastRenderer(
        _regionId,
        _forecastData,
        marginRight
      );
      avalancheForecast.draw(dc);
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

  private function updateForecastData() as Void {
    _forecastData = _skredvarselApi.getForecastForRegion(_regionId);
  }

  public function onReceive() as Void {
    updateForecastData();
    Ui.requestUpdate();
  }

  public function getRegionId() as String {
    return _regionId;
  }
}
