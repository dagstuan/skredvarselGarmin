import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastView extends Ui.View {
  private var _text as Ui.Text;

  private var _skredvarselApi as SkredvarselApi;
  private var _regionId as String;
  private var _forecast as AvalancheForecast?;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    regionId as String
  ) {
    View.initialize();

    _skredvarselApi = skredvarselApi;
    _regionId = regionId;
    var regionName = $.Regions[regionId];

    _text = new Ui.Text({
      :text => regionName,
      :color => Gfx.COLOR_WHITE,
      :backgroundColor => Gfx.COLOR_BLACK,
      :locX => Ui.LAYOUT_HALIGN_CENTER,
      :locY => Ui.LAYOUT_VALIGN_CENTER,
      :justification => Gfx.TEXT_JUSTIFY_CENTER,
    });

    _skredvarselApi.loadForecastForRegionIfRequired(
      _regionId,
      method(:onReceive)
    );
    getForecastFromCache();
  }

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Gfx.Dc) as Void {
    if (_forecast == null) {
      getForecastFromCache();
    } else {
      dc.clear();

      var width = dc.getWidth();
      var height = dc.getHeight();

      var iconResource = $.getIconResourceForDangerLevel(
        _forecast.getDangerLevelToday()
      );

      var icon = WatchUi.loadResource(iconResource);

      var iconX = width / 2 - $.halfWidthDangerLevelIcon;

      dc.drawBitmap(iconX, height / 2 - 60, icon);

      _text.draw(dc);
    }
  }

  private function getForecastFromCache() as Void {
    _forecast = _skredvarselApi.getForecastForRegion(_regionId);
  }

  public function onReceive() as Void {
    getForecastFromCache();
    Ui.requestUpdate();
  }
}
