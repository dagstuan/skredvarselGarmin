import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastMenuEditMenuItem extends Ui.CustomMenuItem {
  public function initialize(id as String) {
    CustomMenuItem.initialize(id, {});
  }

  public function draw(dc as Gfx.Dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    var editText = Ui.loadResource($.Rez.Strings.Edit);

    dc.drawText(
      (dc.getWidth() - ForecastMenu.Margin) / 2,
      dc.getHeight() / 2,
      Graphics.FONT_MEDIUM,
      editText,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
