import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastMenuEditMenuItem extends Ui.CustomMenuItem {
  private var _screenWidth as Number;
  private var _text as String;

  public function initialize(id as String) {
    CustomMenuItem.initialize(id, {});

    _screenWidth = $.getDeviceScreenWidth();
    _text = $.getOrLoadResourceString("Velg regioner", :PickRegions);
  }

  public function draw(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    var paddingLeft = width == _screenWidth ? 10 : 0;
    var paddingRight = width == _screenWidth ? 10 : 25;

    var contentWidth = width - paddingLeft - paddingRight;

    if ($.DrawOutlines) {
      $.drawOutline(dc, paddingLeft, 0, contentWidth, height);
    }

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    var font = Graphics.FONT_SMALL;

    dc.drawText(
      paddingLeft + contentWidth / 2,
      height / 2,
      font,
      _text,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
