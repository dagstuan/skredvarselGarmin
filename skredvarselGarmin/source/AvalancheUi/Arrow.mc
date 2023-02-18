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
    private var _locX as Numeric;
    private var _locY as Numeric;
    private var _width as Numeric;
    private var _height as Numeric;
    private var _color as Gfx.ColorType;
    private var _direction as ArrowDirection;

    public function initialize(settings as ArrowSettings) {
      _locX = settings[:locX];
      _locY = settings[:locY];
      _width = settings[:width];
      _height = settings[:height];
      _color = settings[:color];
      _direction = settings[:direction];
    }

    public function draw(dc as Gfx.Dc) {
      dc.setColor(_color, _color);

      if (_direction == UP) {
        drawUpArrow(dc);
      } else if (_direction == DOWN) {
        drawDownArrow(dc);
      }
    }

    private function drawUpArrow(dc as Gfx.Dc) {
      var shaftWidth = 0.3334 * _width;
      var shaftHeight = 0.5 * _height;

      dc.fillPolygon([
        [_locX, _locY + shaftHeight],
        [_locX + _width / 2, _locY],
        [_locX + _width, _locY + shaftHeight],
        [_locX + _width - shaftWidth, _locY + shaftHeight],
        [_locX + _width - shaftWidth, _locY + _height],
        [_locX + shaftWidth, _locY + _height],
        [_locX + shaftWidth, _locY + _height - shaftHeight],
      ]);
    }

    private function drawDownArrow(dc as Gfx.Dc) {
      var shaftWidth = 0.3334 * _width;
      var shaftHeight = 0.5 * _height;

      dc.fillPolygon([
        [_locX, _locY + shaftHeight],
        [_locX + _width / 2, _locY],
        [_locX + _width, _locY + shaftHeight],
        [_locX + _width - shaftWidth, _locY + shaftHeight],
        [_locX + _width - shaftWidth, _locY + _height],
        [_locX + shaftWidth, _locY + _height],
        [_locX + shaftWidth, _locY + _height - shaftHeight],
      ]);
    }
  }
}
