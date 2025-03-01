import Toybox.Lang;

using Toybox.Graphics as Gfx;

(:glance)
function getPoints(size as Number, x0 as Numeric, y0 as Numeric) {
  var scale = size / 100.0;

  return [
    [x0 + 87.13 * scale, y0 + 0.0 * scale],
    [x0 + 86.49 * scale, y0 + 0.09 * scale],
    [x0 + 85.61 * scale, y0 + 0.55 * scale],
    [x0 + 11.34 * scale, y0 + 62.37 * scale],
    [x0 + 12.96 * scale, y0 + 66.59 * scale],
    [x0 + 50.92 * scale, y0 + 65.11 * scale],
    [x0 + 68.62 * scale, y0 + 98.73 * scale],
    [x0 + 73.08 * scale, y0 + 98.02 * scale],
    [x0 + 89.48 * scale, y0 + 2.79 * scale],
    [x0 + 87.14 * scale, y0 + 0.0 * scale],
  ];
}

module AvalancheUi {
  (:glance)
  public class NavigationIcon {
    (:useBufferedBitmapOnGlance)
    private var _bufferedBitmap as Gfx.BufferedBitmap?;

    public var size as Number;

    public function initialize(initSize as Number) {
      size = initSize;
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      if (self has :drawBuffered) {
        drawBuffered(dc, x0, y0);
      } else {
        drawNonBuffered(dc, x0, y0);
      }
    }

    (:useBufferedBitmapOnGlance)
    function drawBuffered(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      if (_bufferedBitmap == null) {
        _bufferedBitmap = $.newBufferedBitmap({
          :width => size,
          :height => size,
          :palette => [Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLUE],
        });

        var bufferedDc = _bufferedBitmap.getDc();

        bufferedDc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        bufferedDc.fillPolygon($.getPoints(size, 0, 0));
      }

      dc.drawBitmap(x0, y0, _bufferedBitmap);
    }

    private function drawNonBuffered(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);

      var points = $.getPoints(size, x0, y0);

      dc.fillPolygon(points);
    }
  }
}
