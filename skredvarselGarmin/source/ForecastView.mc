import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastView extends Ui.View {
  private var _text as Ui.Text;

  public function initialize(regionId as String) {
    View.initialize();

    var regionName = $.Regions[regionId];

    _text = new Ui.Text({
      :text => regionName,
      :color => Gfx.COLOR_WHITE,
      :backgroundColor => Gfx.COLOR_BLACK,
      :locX => Ui.LAYOUT_HALIGN_CENTER,
      :locY => Ui.LAYOUT_VALIGN_CENTER,
      :justification => Gfx.TEXT_JUSTIFY_CENTER,
    });
  }

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    _text.draw(dc);
  }
}
