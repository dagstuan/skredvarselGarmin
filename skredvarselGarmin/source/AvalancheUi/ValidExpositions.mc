import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  typedef ValidExpositionsSettings as {
    :validExpositions as String,
    :locX as Numeric,
    :locY as Numeric,
    :radius as Numeric,
    :dangerFillColor as Gfx.ColorType,
    :nonDangerFillColor as Gfx.ColorType,
  };

  public class ValidExpositions {
    private var _validExpositions as Array<Char>;
    private var _locX as Numeric;
    private var _locY as Numeric;
    private var _radius as Numeric;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    public function initialize(settings as ValidExpositionsSettings) {
      _validExpositions = settings[:validExpositions].toCharArray();
      _locX = settings[:locX];
      _locY = settings[:locY];
      _radius = settings[:radius];
      _dangerFillColor = settings[:dangerFillColor];
      _nonDangerFillColor = settings[:nonDangerFillColor];

      var numChars = _validExpositions.size();
      if (numChars != 8) {
        throw new SkredvarselGarminException(
          "Invalid char array for valid expositions."
        );
      }
    }

    public function draw(dc as Gfx.Dc) {
      dc.setPenWidth(_radius);
      dc.setAntiAlias(true);

      var anglePerChar = 360 / 8;
      var originalStartAngle = 90 + Math.ceil(anglePerChar / 2);
      var startAngle = originalStartAngle;
      // Draw cake slices
      for (var i = 0; i < 8; i++) {
        var currChar = _validExpositions[i];

        var endAngle = (startAngle - anglePerChar) % 360;

        if (currChar == '0') {
          dc.setColor(_nonDangerFillColor, _nonDangerFillColor);
        } else {
          dc.setColor(_dangerFillColor, _dangerFillColor);
        }

        dc.drawArc(
          _locX,
          _locY,
          _radius / 2,
          Gfx.ARC_CLOCKWISE,
          startAngle,
          endAngle
        );

        startAngle = endAngle;
      }

      var lineColor = Gfx.COLOR_BLACK;

      dc.setPenWidth(1);
      dc.setColor(lineColor, lineColor);

      // draw lines
      startAngle = originalStartAngle;
      for (var i = 0; i < 4; i++) {
        var endAngle = (startAngle + 180) % 360;
        var start = calcCirclePoint(_locX, _locY, _radius, startAngle);
        var end = calcCirclePoint(_locX, _locY, _radius, endAngle);

        dc.drawLine(start[0], start[1], end[0], end[1]);
        startAngle = (startAngle + 45) % 360;
      }
    }
  }

  function calcCirclePoint(
    cX as Numeric,
    cY as Numeric,
    r as Numeric,
    theta as Numeric
  ) as Array<Numeric> {
    return [
      cX + r * Math.cos(Math.toRadians(theta)),
      cY + r * Math.sin(Math.toRadians(theta)),
    ];
  }
}
