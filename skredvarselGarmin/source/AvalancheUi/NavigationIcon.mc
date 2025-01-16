import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  (:glance)
  public class NavigationIcon {
    private var _bufferedBitmap as Gfx.BufferedBitmap?;
    public var size as Number;

    public function initialize(initSize as Number) {
      size = initSize;

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

    private function getPoints() {
      var scale = size / 100.0;

      return [
        [87.13 * scale, 0.0 * scale],
        [86.49 * scale, 0.09 * scale],
        [85.61 * scale, 0.55 * scale],
        [11.34 * scale, 62.37 * scale],
        [12.96 * scale, 66.59 * scale],
        [50.92 * scale, 65.11 * scale],
        [68.62 * scale, 98.73 * scale],
        [73.08 * scale, 98.02 * scale],
        [89.48 * scale, 2.79 * scale],
        [87.14 * scale, 0.0 * scale],
      ];
    }
  }
}
