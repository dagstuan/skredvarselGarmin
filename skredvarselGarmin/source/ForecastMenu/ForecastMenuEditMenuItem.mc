import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastMenuEditMenuItem extends Ui.CustomMenuItem {
  private var _screenWidth as Number;

  public function initialize(id as String) {
    CustomMenuItem.initialize(id, {});

    _screenWidth = $.getDeviceScreenWidth();
  }

  public function draw(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    var paddingLeft = width == _screenWidth ? 10 : 0;
    var paddingRight = width == _screenWidth ? 10 : 25;

    var contentWidth = width - paddingLeft - paddingRight;

    $.drawOutline(dc, paddingLeft, 0, contentWidth, height);

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    var text = Ui.loadResource($.Rez.Strings.Edit);
    var font = Graphics.FONT_MEDIUM;

    dc.drawText(
      paddingLeft + contentWidth / 2,
      height / 2,
      font,
      text,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
