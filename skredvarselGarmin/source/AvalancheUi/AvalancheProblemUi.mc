import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  typedef AvalancheProblemSettings as {
    :problem as AvalancheProblem,
    :locX as Numeric,
    :locY as Numeric,
    :width as Numeric,
    :height as Numeric,
    :dangerFillColor as Gfx.ColorType,
    :nonDangerFillColor as Gfx.ColorType,
  };

  public class AvalancheProblemUi {
    private var _problem as AvalancheProblem;
    private var _locX as Numeric;
    private var _locY as Numeric;
    private var _width as Numeric;
    private var _height as Numeric;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    private var _padding = 5;
    private var _halfWidth as Number;
    private var _quarterWidth as Number;
    private var _halfHeight as Number;
    private var _quarterHeight as Number;

    private var _textPaddingTop = 10;
    private var _textPaddingBottom = 12;

    public function initialize(settings as AvalancheProblemSettings) {
      _problem = settings[:problem];
      _locX = settings[:locX];
      _locY = settings[:locY];
      _width = settings[:width];
      _height = settings[:height];

      _dangerFillColor = Gfx.COLOR_RED;
      _nonDangerFillColor = Gfx.COLOR_LT_GRAY;

      _halfWidth = _width / 2;
      _quarterWidth = _width / 4;
      _halfHeight = _height / 2;
      _quarterHeight = _height / 4;
    }

    public function draw(dc as Gfx.Dc) {
      // drawOutlines(dc);
      drawExpositions(dc);
      drawExposedHeights(dc);
      drawHeightText(dc);
      drawDivider(dc);
      drawProblemText(dc);
    }

    private function drawOutlines(dc as Gfx.Dc) {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
      dc.setPenWidth(1);
      dc.drawRectangle(_locX, _locY, _width, _height);

      dc.drawLine(
        _locX,
        _locY + _height * 0.5,
        _locX + _width,
        _locY + _height * 0.5
      );

      dc.drawLine(
        _locX + _width * 0.5,
        _locY,
        _locX + _width * 0.5,
        _locY + _height
      );
    }

    private function drawExpositions(dc as Gfx.Dc) {
      var expositionsRadius = _height / 4 - _padding / 2;

      var validExpositions = new AvalancheUi.ValidExpositions({
        :validExpositions => _problem.validExpositions,
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :locX => _locX + _quarterWidth * 2 - expositionsRadius * 2,
        :locY => _locY + _height - expositionsRadius,
        :radius => expositionsRadius,
      });

      validExpositions.draw(dc);
    }

    private function drawExposedHeights(dc as Gfx.Dc) {
      var scaleDown = 10;
      var exposedWidth = _quarterWidth - _padding / 2 - scaleDown;

      var exposedHeightUi = new AvalancheUi.ExposedHeight({
        :exposedHeight1 => _problem.exposedHeight1,
        :exposedHeight2 => _problem.exposedHeight2,
        :exposedHeightFill => _problem.exposedHeightFill,
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :locX => _locX + scaleDown,
        :locY => _locY + scaleDown,
        :size => exposedWidth,
      });

      exposedHeightUi.draw(dc);
    }

    private function drawHeightText(dc as Gfx.Dc) {
      if (_problem.exposedHeightFill == 1) {
        drawHeightTextBottom(dc, _problem.exposedHeight1 + "m");
        drawHeightArrowTop(dc);
      }
    }

    private function drawHeightTextBottom(dc as Gfx.Dc, text as String) {
      var font = Gfx.FONT_XTINY;
      var fontHeight = Gfx.getFontHeight(font);
      var textWidth = dc.getTextWidthInPixels(text, font);

      var textX0 = _locX + _quarterWidth + _quarterWidth / 2;
      var textY0 = _locY + _halfHeight - fontHeight - _textPaddingBottom;

      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.drawText(textX0, textY0, font, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    private function drawHeightArrowTop(dc as Gfx.Dc) {
      var arrowWidth = 20;
      var arrowHeight = _quarterHeight - _textPaddingTop;

      var arrowX = _locX + _halfWidth - _quarterWidth / 2 - arrowWidth / 2;
      var arrowY = _locY + _textPaddingTop;
      var arrow = new AvalancheUi.Arrow({
        :locX => arrowX,
        :locY => arrowY,
        :width => arrowWidth,
        :height => arrowHeight,
        :color => _dangerFillColor,
        :direction => UP,
      });

      arrow.draw(dc);
    }

    private function drawDivider(dc as Gfx.Dc) {
      dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
      dc.setPenWidth(1);

      var offsetTopBottom = _height * 0.2;

      dc.drawLine(
        _locX + _halfWidth,
        _locY + offsetTopBottom,
        _locX + _halfWidth,
        _locY + _height - offsetTopBottom
      );
    }

    private function drawProblemText(dc as Gfx.Dc) {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      var text = _problem.avalancheProblemTypeName;
      var font = Gfx.FONT_XTINY;

      var padding = 10;

      var textWidth = _halfWidth - padding * 2;
      var textHeight = _height - padding * 2;

      var x0 = _locX + _halfWidth + _quarterWidth;
      var y0 = _locY + _halfHeight;

      // var rectx0 = _locX + _halfWidth + padding;
      // var recty0 = _locY + padding;
      // dc.drawRectangle(rectx0, recty0, textWidth, textHeight);

      var fitText = Gfx.fitTextToArea(text, font, textWidth, textHeight, true);

      dc.drawText(
        x0,
        y0,
        font,
        fitText,
        Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
      );
    }
  }
}
