import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  public enum TextElementsAlignment {
    TOP = 0,
    BOTTOM = 1,
  }

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

    private var _padding = 0;
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
      drawOutlines(dc);
      drawExpositions(dc);
      drawExposedHeights(dc);
      drawHeightTextElements(dc);
      drawDivider(dc);
      drawProblemText(dc);
    }

    private function drawOutlines(dc as Gfx.Dc) {
      if (!$.DrawOutlines) {
        return;
      }

      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
      dc.setPenWidth(1);
      $.drawOutline(dc, _locX, _locY, _width, _height);

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
      var x0 = _locX + _quarterWidth / 2;
      var y0 = _locY + _halfHeight;
      var width = _quarterWidth;
      var height = _halfHeight;
      var sizeModifier = 1;
      $.drawOutline(dc, x0, y0, width, height);

      var validExpositions = new AvalancheUi.ValidExpositions({
        :validExpositions => _problem.validExpositions,
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :locX => x0 + width / 2,
        :locY => y0 + height / 2,
        :radius => (width / 2) * sizeModifier,
      });

      validExpositions.draw(dc);
    }

    private function drawExposedHeights(dc as Gfx.Dc) {
      var x0 = _locX;
      var y0 = _locY;
      var width = _quarterWidth;
      var height = _halfHeight;
      $.drawOutline(dc, x0, y0, width, height);
      var sizeModifier = 0.9;
      var exposedWidth = _quarterWidth * sizeModifier;

      var exposedHeightUi = new AvalancheUi.ExposedHeight({
        :exposedHeight1 => _problem.exposedHeight1,
        :exposedHeight2 => _problem.exposedHeight2,
        :exposedHeightFill => _problem.exposedHeightFill,
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :locX => x0 + (width / 2 - exposedWidth / 2),
        :locY => y0 + (height / 2 - exposedWidth / 2),
        :size => exposedWidth,
      });

      exposedHeightUi.draw(dc);
    }

    private function drawHeightTextElements(dc as Gfx.Dc) {
      var contentX0 = _locX + _quarterWidth;
      var topContentY0 = _locY;
      var contentWidth = _quarterWidth;
      var contentHeight = _quarterHeight;

      $.drawOutline(dc, contentX0, topContentY0, contentWidth, contentHeight);

      var bottomContentY0 = _locY + _quarterHeight;

      $.drawOutline(
        dc,
        contentX0,
        bottomContentY0,
        contentWidth,
        contentHeight
      );

      if (_problem.exposedHeightFill == 1) {
        drawHeightArrow(
          dc,
          contentX0,
          topContentY0,
          contentHeight,
          contentWidth,
          BOTTOM,
          UP
        );
        drawHeightText(
          dc,
          contentX0,
          bottomContentY0,
          contentHeight,
          contentWidth,
          TOP,
          _problem.exposedHeight1 + "m"
        );
      }
      if (_problem.exposedHeightFill == 2) {
        drawHeightText(
          dc,
          contentX0,
          topContentY0,
          contentHeight,
          contentWidth,
          BOTTOM,
          _problem.exposedHeight1 + "m"
        );
        drawHeightArrow(
          dc,
          contentX0,
          bottomContentY0,
          contentHeight,
          contentWidth,
          TOP,
          DOWN
        );
      }

      // TODO: Exposedheightfill3 og 4
    }

    private function drawHeightText(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric,
      height as Numeric,
      width as Numeric,
      alignment as TextElementsAlignment,
      text as String
    ) {
      var font = Gfx.FONT_XTINY;
      var fontHeight = Gfx.getFontHeight(font);
      var textWidth = dc.getTextWidthInPixels(text, font);

      var textX0 = x0 + width / 2;
      var textY0 =
        alignment == TOP ? y0 + fontHeight / 2 : y0 + height - fontHeight / 2;

      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.drawText(
        textX0,
        textY0,
        font,
        text,
        Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
      );
    }

    private function drawHeightArrow(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric,
      height as Numeric,
      width as Numeric,
      alignment as TextElementsAlignment,
      direction as AvalancheUi.ArrowDirection
    ) {
      var heightModifier = 0.7;
      var arrowWidth = 15;
      var arrowHeight = height * heightModifier;

      var arrowY0 = alignment == TOP ? y0 : y0 + height - arrowHeight;

      var arrow = new AvalancheUi.Arrow({
        :locX => x0 + width / 2 - arrowWidth / 2,
        :locY => arrowY0,
        :width => arrowWidth,
        :height => arrowHeight,
        :color => _dangerFillColor,
        :direction => direction,
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

      var textWidth = _halfWidth;
      var textHeight = _height;

      var x0 = _locX + _halfWidth + _quarterWidth;
      var y0 = _locY + _halfHeight;

      var rectx0 = _locX + _halfWidth;
      var recty0 = _locY;
      $.drawOutline(dc, rectx0, recty0, textWidth, textHeight);
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
