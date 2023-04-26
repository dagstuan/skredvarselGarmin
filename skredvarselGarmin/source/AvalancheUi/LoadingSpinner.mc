import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  typedef LoadingSpinnerSettings as {
    :locX as Numeric,
    :locY as Numeric,
    :radius as Numeric,
  };

  public class LoadingSpinner {
    private var _locX as Numeric;
    private var _locY as Numeric;
    private var _radius as Numeric;

    private var _angle as Numeric = 0;
    private var _anglePerTick = 40;

    private var _penWidth = 2;

    public function initialize(settings as LoadingSpinnerSettings) {
      _radius = settings[:radius];
      _locX = settings[:locX];
      _locY = settings[:locY];
    }

    public function onTick() {
      _angle = (_angle - _anglePerTick) % 360;
    }

    public function draw(dc as Gfx.Dc) {
      dc.setAntiAlias(true);
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.setPenWidth(_penWidth);

      dc.drawArc(
        _locX,
        _locY,
        _radius - _penWidth / 2.0,
        Gfx.ARC_CLOCKWISE,
        _angle,
        (_angle - 270) % 360
      );
    }
  }
}
