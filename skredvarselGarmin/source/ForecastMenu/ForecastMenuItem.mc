import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastMenuItem extends Ui.CustomMenuItem {
  private var _regionId as String;
  private var _skredvarselApi as SkredvarselApi;

  private var _forecast as AvalancheForecast?;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    regionId as String
  ) {
    CustomMenuItem.initialize(regionId, {});

    _skredvarselApi = skredvarselApi;
    _regionId = regionId;

    _skredvarselApi.loadForecastForRegionIfRequired(
      _regionId,
      method(:onReceive)
    );
    getForecastFromCache();
  }

  //! Draw the item string at the center of the item.
  //! @param dc Device context
  public function draw(dc) as Void {
    if (_forecast == null) {
      getForecastFromCache();
    }

    if (_forecast != null) {
      var avalancheForecast = new AvalancheForecastRenderer(
        _regionId,
        _forecast,
        ForecastMenu.MarginRight
      );
      avalancheForecast.draw(dc);
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
    _forecast = _skredvarselApi.getForecastForRegion(_regionId);
  }

  public function onReceive() as Void {
    getForecastFromCache();
    Ui.requestUpdate();
  }

  public function getRegionId() as String {
    return _regionId;
  }
}
