import Toybox.Lang;

using Toybox.Graphics as Gfx;

(:glance)
function getPoints() {
  return [
    [11.3269, 0],
    [11.2437, 0.0117],
    [11.1293, 0.07150000000000001],
    [1.4742, 8.1081],
    [1.6848, 8.6567],
    [6.6196, 8.4643],
    [8.9206, 12.834900000000001],
    [9.5004, 12.7426],
    [11.6324, 0.3627],
    [11.3282, 0],
  ];
}

module AvalancheUi {
  (:glance)
  public class NavigationIcon {
    private var _bufferedBitmap as Gfx.BufferedBitmap?;
    public var size = 13;

    public function initialize() {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => size,
        :height => size,
        :palette => [Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLUE],
      });

      var bufferedDc = _bufferedBitmap.getDc();

      bufferedDc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      bufferedDc.fillPolygon(getPoints());
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      dc.drawBitmap(x0, y0, _bufferedBitmap);
    }
  }
}
