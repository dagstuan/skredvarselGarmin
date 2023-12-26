import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.WatchUi as Ui;

module AvalancheUi {
  typedef ValidExpositionsSettings as {
    :validExpositions as String,
    :radius as Numeric,
    :dangerFillColor as Gfx.ColorType,
    :nonDangerFillColor as Gfx.ColorType,
  };

  public class ValidExpositions {
    private var _radius as Numeric;
    private var _font as Ui.Resource = Ui.loadResource($.Rez.Fonts.roboto);
    private var _fontHeight as Number = Gfx.getFontHeight(_font);

    private var _bufferedBitmap as Gfx.BufferedBitmap;

    public function initialize(settings as ValidExpositionsSettings) {
      _radius = settings[:radius];

      _bufferedBitmap = createBufferedBitmap(settings);
    }

    private function createBufferedBitmap(
      settings as ValidExpositionsSettings
    ) as Gfx.BufferedBitmap {
      var validExpositions = settings[:validExpositions].toCharArray();
      var numChars = validExpositions.size();
      if (numChars != 8) {
        throw new SkredvarselGarminException(
          "Invalid char array for valid expositions."
        );
      }
      var dangerFillColor = settings[:dangerFillColor];
      var nonDangerFillColor = settings[:nonDangerFillColor];
      var bufferedBitmap = $.newBufferedBitmap({
        :width => _radius * 2,
        :height => _radius * 2 + _fontHeight,
      });

      var bufferedDc = bufferedBitmap.getDc();

      bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      bufferedDc.drawText(
        _radius,
        _fontHeight / 2,
        _font,
        "N",
        Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
      );

      if ($.DrawOutlines) {
        $.drawOutline(bufferedDc, 0, 0, _radius * 2, _radius * 2 + _fontHeight);
      }

      bufferedDc.setPenWidth(_radius);
      bufferedDc.setAntiAlias(true);

      var anglePerChar = 360 / 8;
      var originalStartAngle = 90 + Math.ceil(anglePerChar / 2);
      var startAngle = originalStartAngle;

      var centerX = _radius;
      var centerY = _radius + _fontHeight;

      // Draw cake slices
      for (var i = 0; i < 8; i++) {
        var currChar = validExpositions[i];

        var endAngle = (startAngle - anglePerChar) % 360;

        if (currChar == '0') {
          bufferedDc.setColor(nonDangerFillColor, nonDangerFillColor);
        } else {
          bufferedDc.setColor(dangerFillColor, dangerFillColor);
        }

        bufferedDc.drawArc(
          centerX,
          centerY,
          _radius / 2,
          Gfx.ARC_CLOCKWISE,
          startAngle,
          endAngle
        );

        startAngle = endAngle;
      }

      var lineColor = Gfx.COLOR_BLACK;

      bufferedDc.setPenWidth(1);
      bufferedDc.setColor(lineColor, lineColor);

      // draw lines
      startAngle = originalStartAngle;
      for (var i = 0; i < 4; i++) {
        var endAngle = (startAngle + 180) % 360;
        var start = calcCirclePoint(centerX, centerY, _radius, startAngle);
        var end = calcCirclePoint(centerX, centerY, _radius, endAngle);

        bufferedDc.drawLine(start[0], start[1], end[0], end[1]);
        startAngle = (startAngle + 45) % 360;
      }

      return bufferedBitmap;
    }

    public function getSize() {
      return _radius * 2;
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      var Y0 = y0 - _fontHeight;

      dc.drawBitmap(x0, Y0, _bufferedBitmap);
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
