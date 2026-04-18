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
    :labelColor as Gfx.ColorType?,
  };

  public class ValidExpositions {
    private var _radius as Numeric;
    private var _font as Ui.Resource = Ui.loadResource($.Rez.Fonts.roboto);
    private var _fontHeight as Number = Gfx.getFontAscent(_font);

    private var _bufferedBitmap as Gfx.BufferedBitmap?;
    private var _validExpositions as Array;
    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;
    private var _labelColor as Gfx.ColorType;

    public function initialize(settings as ValidExpositionsSettings) {
      _radius = settings[:radius];
      _validExpositions = settings[:validExpositions].toCharArray();
      if (_validExpositions.size() != 8) {
        throw new SkredvarselGarminException(
          "Invalid char array for valid expositions."
        );
      }
      _dangerFillColor = settings[:dangerFillColor];
      _nonDangerFillColor = settings[:nonDangerFillColor];
      _labelColor =
        settings[:labelColor] != null ? settings[:labelColor] : Gfx.COLOR_WHITE;

      _bufferedBitmap = createBufferedBitmap(settings);
    }

    (:bufferedBitmaps)
    private function createBufferedBitmap(
      settings as ValidExpositionsSettings
    ) as Gfx.BufferedBitmap {
      var bufferedBitmap = $.newBufferedBitmap({
        :width => _radius * 2,
        :height => _radius * 2 + _fontHeight,
      });

      var bufferedDc = bufferedBitmap.getDc();

      drawToDc(bufferedDc, 0, 0);

      return bufferedBitmap;
    }

    (:noBufferedBitmaps)
    private function createBufferedBitmap(
      settings as ValidExpositionsSettings
    ) as Gfx.BufferedBitmap? {
      return null;
    }

    private function drawToDc(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) as Void {
      dc.setColor(_labelColor, Gfx.COLOR_TRANSPARENT);
      dc.drawText(
        x0 + _radius,
        y0 + _fontHeight / 2,
        _font,
        "N",
        Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
      );

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _radius * 2, _radius * 2 + _fontHeight);
      }

      dc.setPenWidth(_radius);

      if (dc has :setAntiAlias) {
        dc.setAntiAlias(true);
      }

      var anglePerChar = 360 / 8;
      var originalStartAngle = 90 + Math.ceil(anglePerChar / 2);
      var startAngle = originalStartAngle;

      var centerX = x0 + _radius;
      var centerY = y0 + _radius + _fontHeight;

      for (var i = 0; i < 8; i++) {
        var currChar = _validExpositions[i];
        var endAngle = (startAngle - anglePerChar) % 360;

        if (currChar == '0') {
          dc.setColor(_nonDangerFillColor, _nonDangerFillColor);
        } else {
          dc.setColor(_dangerFillColor, _dangerFillColor);
        }

        dc.drawArc(
          centerX,
          centerY,
          _radius / 2,
          Gfx.ARC_CLOCKWISE,
          startAngle,
          endAngle
        );

        startAngle = endAngle;
      }

      dc.setPenWidth(1);
      dc.setColor($.CurrentBgColor, Gfx.COLOR_TRANSPARENT);

      startAngle = originalStartAngle;
      for (var i = 0; i < 4; i++) {
        var endAngle = (startAngle + 180) % 360;
        var start = calcCirclePoint(centerX, centerY, _radius, startAngle);
        var end = calcCirclePoint(centerX, centerY, _radius, endAngle);

        dc.drawLine(start[0], start[1], end[0], end[1]);
        startAngle = (startAngle + 45) % 360;
      }
    }

    public function getSize() {
      return _radius * 2;
    }

    public function getTotalHeight() as Number {
      return _radius * 2 + _fontHeight;
    }

    (:bufferedBitmaps)
    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      var Y0 = y0 - _fontHeight;

      dc.drawBitmap(x0, Y0, _bufferedBitmap);
    }

    (:noBufferedBitmaps)
    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      drawToDc(dc, x0, y0 - _fontHeight);
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
