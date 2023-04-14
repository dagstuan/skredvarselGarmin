import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  class PageIndicator {
    public var visibilityPercent as Number;

    private var _indicatorSize = 8;
    private var _paddingFromEdge = 6;

    private var _centerAngle = 270;
    private var _anglePerPage = 6;

    public function initialize() {
      visibilityPercent = 100;
    }

    public function draw(
      dc as Gfx.Dc,
      numPages as Number,
      selectedIndex as Number
    ) as Void {
      if (visibilityPercent == 0) {
        return;
      }

      dc.setAntiAlias(false);
      dc.setPenWidth(1);
      var width = dc.getWidth();
      var height = dc.getHeight();

      var cX = width / 2;
      var cY = height / 2;

      var radModifier = 1 - visibilityPercent / 100;
      var mod = _paddingFromEdge * 2.5 * radModifier;
      var rad = width / 2 - _paddingFromEdge + mod; // Assume circular screen

      var angle =
        _centerAngle - (numPages * _anglePerPage - _indicatorSize) / 2;

      var x0 = cX + rad * Math.sin(Math.toRadians(angle));
      var y0 = cY + rad * Math.cos(Math.toRadians(angle));

      for (var i = 0; i < numPages; i++) {
        x0 = cX + rad * Math.sin(Math.toRadians(angle));
        y0 = cY + rad * Math.cos(Math.toRadians(angle));

        if (i == selectedIndex) {
          dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
          dc.fillCircle(x0, y0, _indicatorSize / 2);
        } else {
          dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
          dc.drawCircle(x0, y0, _indicatorSize / 2);
        }

        angle += _anglePerPage;
      }
    }
  }
}
