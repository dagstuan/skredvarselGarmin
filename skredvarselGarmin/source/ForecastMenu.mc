import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application.Storage;
using Toybox.Graphics as Gfx;

public class ForecastMenu extends WatchUi.CustomMenu {
  private var _logo as BitmapResource?;

  public function initialize(skredvarselApi) {
    CustomMenu.initialize(60, Graphics.COLOR_BLACK, {});

    var regionIds = skredvarselApi.getSelectedRegionIds() as Array<String>;

    for (var i = 0; i < regionIds.size(); i++) {
      addItem(new ForecastMenuItem(skredvarselApi, regionIds[i], i.toString()));
    }

    _logo =
      WatchUi.loadResource($.Rez.Drawables.LauncherIcon) as BitmapResource;
  }

  function drawTitle(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    if (_logo != null) {
      var offsetX = _logo.getWidth() / 2;
      var logoX = width / 2 - offsetX;

      dc.drawBitmap(logoX, 10, _logo);
    }

    dc.drawText(
      width / 2,
      height / 2 + 15,
      Graphics.FONT_XTINY,
      "Skredvarsel",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setPenWidth(1);

    var offsetFromBottom = 15;
    var marginLeftRight = 35;

    dc.drawLine(
      marginLeftRight,
      height - offsetFromBottom,
      width - marginLeftRight,
      height - offsetFromBottom
    );
  }
}
