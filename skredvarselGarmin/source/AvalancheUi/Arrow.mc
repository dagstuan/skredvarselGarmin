import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  public enum ArrowDirection {
    UP = 0,
    DOWN = 1,
  }

  typedef ArrowSettings as {
    :locX as Numeric,
    :locY as Numeric,
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

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      dc.drawBitmap(x0, y0, _bufferedBitmap);
    }

    private function createBufferedBitmap() {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _width,
        :height => _height,
        :palette => [Gfx.COLOR_TRANSPARENT, _color],
      });

      var bufferedDc = _bufferedBitmap.getDc();

      bufferedDc.setColor(_color, _color);

      if (_direction == UP) {
        drawUpArrow(bufferedDc);
      } else if (_direction == DOWN) {
        drawDownArrow(bufferedDc);
      }
    }

    private function drawUpArrow(dc as Gfx.Dc) {
      var shaftWidth = 0.3334 * _width;
      var shaftHeight = 0.5 * _height;

      dc.fillPolygon([
        [0, shaftHeight],
        [_width / 2, 0],
        [_width, shaftHeight],
        [_width - shaftWidth, shaftHeight],
        [_width - shaftWidth, _height],
        [shaftWidth, _height],
        [shaftWidth, _height - shaftHeight],
      ]);
    }

    private function drawDownArrow(dc as Gfx.Dc) {
      var shaftWidth = 0.3334 * _width;
      var shaftHeight = 0.5 * _height;
      var spaceLeftRight = (_width - shaftWidth) / 2;

      dc.fillPolygon([
        [0, shaftHeight],
        [spaceLeftRight, shaftHeight],
        [spaceLeftRight, 0],
        [spaceLeftRight + shaftWidth, 0],
        [spaceLeftRight + shaftWidth, shaftHeight],
        [_width, shaftHeight],
        [_width / 2, _height],
      ]);
    }
  }
}
