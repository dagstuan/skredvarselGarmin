import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  public enum ArrowDirection {
    UP = 0,
    DOWN = 1,
  }

  typedef ArrowSettings as {
    :width as Numeric,
    :height as Numeric,
    :color as Gfx.ColorType,
    :direction as ArrowDirection,
  };

  public class Arrow {
    private var _width as Numeric;
    private var _height as Numeric;
    private var _color as Gfx.ColorType;
    private var _direction as ArrowDirection;

    private var _bufferedBitmap as Gfx.BufferedBitmap?;

    public function initialize(settings as ArrowSettings) {
      _width = settings[:width];
      _height = settings[:height];
      _color = settings[:color];
      _direction = settings[:direction];

      createBufferedBitmap();
    }

    public function getWidth() {
      return _width;
    }

    (:bufferedBitmaps)
    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      dc.drawBitmap(x0, y0, _bufferedBitmap);
    }

    (:noBufferedBitmaps)
    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      dc.setColor(_color, _color);

      if (_direction == UP) {
        drawUpArrow(dc, x0, y0);
      } else if (_direction == DOWN) {
        drawDownArrow(dc, x0, y0);
      }
    }

    (:bufferedBitmaps)
    private function createBufferedBitmap() {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _width,
        :height => _height,
        :palette => [Gfx.COLOR_TRANSPARENT, _color],
      });

      var bufferedDc = _bufferedBitmap.getDc();
      bufferedDc.setColor(_color, _color);

      if (_direction == UP) {
        drawUpArrow(bufferedDc, 0, 0);
      } else if (_direction == DOWN) {
        drawDownArrow(bufferedDc, 0, 0);
      }
    }

    (:noBufferedBitmaps)
    private function createBufferedBitmap() {}

    private function drawUpArrow(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      var shaftWidth = 0.3334 * _width;
      var shaftHeight = 0.5 * _height;

      dc.fillPolygon([
        [x0, y0 + shaftHeight],
        [x0 + _width / 2, y0],
        [x0 + _width, y0 + shaftHeight],
        [x0 + _width - shaftWidth, y0 + shaftHeight],
        [x0 + _width - shaftWidth, y0 + _height],
        [x0 + shaftWidth, y0 + _height],
        [x0 + shaftWidth, y0 + _height - shaftHeight],
      ]);
    }

    private function drawDownArrow(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      var shaftWidth = 0.3334 * _width;
      var shaftHeight = 0.5 * _height;
      var spaceLeftRight = (_width - shaftWidth) / 2;

      dc.fillPolygon([
        [x0, y0 + shaftHeight],
        [x0 + spaceLeftRight, y0 + shaftHeight],
        [x0 + spaceLeftRight, y0],
        [x0 + spaceLeftRight + shaftWidth, y0],
        [x0 + spaceLeftRight + shaftWidth, y0 + shaftHeight],
        [x0 + _width, y0 + shaftHeight],
        [x0 + _width / 2, y0 + _height],
      ]);
    }
  }
}
