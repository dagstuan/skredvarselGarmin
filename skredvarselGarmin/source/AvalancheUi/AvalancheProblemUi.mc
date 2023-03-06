import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  public enum TextElementsAlignment {
    TOP = 0,
    BOTTOM = 1,
    CENTER = 2,
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
    private var _width as Numeric;
    private var _height as Numeric;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    private var _bufferedBitmap as Gfx.BufferedBitmap?;

    private var _problemText as AvalancheUi.ScrollingText?;

    public function initialize(settings as AvalancheProblemSettings) {
      _problem = settings[:problem];
      _width = settings[:width];
      _height = settings[:height];

      _dangerFillColor = Gfx.COLOR_RED;
      _nonDangerFillColor = Gfx.COLOR_LT_GRAY;
    }

    public function onShow() as Void {
      if (_problemText != null) {
        _problemText.onShow();
      }
    }

    public function onHide() as Void {
      if (_problemText != null) {
        _problemText.onHide();
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      if (_problemText == null) {
        _problemText = new ScrollingText({
          :text => _problem["typeName"],
          :width => _width,
          :height => _height * 0.25,
        });
      }

      _problemText.draw(dc, x0, y0);

      // Draw the rest on a single buffered bitmap.
      if (_bufferedBitmap == null) {
        createBufferedBitmap();
      }

      dc.drawBitmap(x0, y0, _bufferedBitmap);
    }

    private function createBufferedBitmap() {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _width,
        :height => _height,
      });

      var bufferedDc = _bufferedBitmap.getDc();

      drawOutlines(bufferedDc);

      var paddingLeftRight = _width * 0.1;
      var paddingBetween = _width * 0.05;
      var elemHeight = _height * 0.75;
      var elemWidth = (_width - paddingLeftRight * 2 - paddingBetween * 2) / 3;

      var x0 = paddingLeftRight;
      var y0 = _height - elemHeight;
      var width = elemWidth;
      var height = elemHeight;

      drawExpositions(bufferedDc, x0, y0, width, height);

      x0 += elemWidth + paddingBetween;
      drawExposedHeights(bufferedDc, x0, y0, width, height);

      x0 += elemWidth + paddingBetween;
      drawHeightTextElements(bufferedDc, x0, y0, width, height);
    }

    private function drawOutlines(dc as Gfx.Dc) {
      if ($.DrawOutlines) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
        dc.setPenWidth(1);
        $.drawOutline(dc, 0, 0, _width, _height);
      }
    }

    private function drawExpositions(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric,
      width as Numeric,
      height as Numeric
    ) {
      var sizeModifier = 1;
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, width, height);
      }

      var minSize = $.min(width, height);

      var validExpositions = new AvalancheUi.ValidExpositions({
        :validExpositions => _problem["validExpositions"],
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :locX => x0 + width / 2,
        :locY => y0 + height / 2,
        :radius => (minSize / 2) * sizeModifier,
      });

      validExpositions.draw(dc);
    }

    private function drawExposedHeights(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric,
      width as Numeric,
      height as Numeric
    ) {
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, width, height);
      }

      var minSize = $.min(width, height);

      var sizeModifier = 0.9;
      var exposedWidth = minSize * sizeModifier;

      var exposedHeights = _problem["exposedHeights"] as Array;

      var exposedHeightUi = new AvalancheUi.ExposedHeight({
        :exposedHeight1 => exposedHeights[0],
        :exposedHeight2 => exposedHeights[1],
        :exposedHeightFill => exposedHeights[2],
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :locX => x0 + (width / 2 - exposedWidth / 2),
        :locY => y0 + (height / 2 - exposedWidth / 2),
        :size => exposedWidth,
      });

      exposedHeightUi.draw(dc);
    }

    private function drawHeightTextElements(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric,
      width as Numeric,
      height as Numeric
    ) {
      var halfHeight = height / 2;

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, width, halfHeight);
      }

      var bottomY0 = y0 + halfHeight;

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, bottomY0, width, halfHeight);
      }

      var exposedHeights = _problem["exposedHeights"] as Array;
      var exposedHeight1 = exposedHeights[0];
      var exposedHeight2 = exposedHeights[1];
      var exposedHeightFill = exposedHeights[2];

      if (exposedHeightFill == 1) {
        drawHeightArrow(dc, x0, y0, halfHeight, width, BOTTOM, UP);
        drawHeightText(
          dc,
          x0,
          bottomY0,
          halfHeight,
          width,
          TOP,
          exposedHeight1 + "m"
        );
      } else if (exposedHeightFill == 2) {
        drawHeightText(
          dc,
          x0,
          y0,
          halfHeight,
          width,
          BOTTOM,
          exposedHeight1 + "m"
        );
        drawHeightArrow(dc, x0, bottomY0, halfHeight, width, TOP, DOWN);
      } else if (exposedHeightFill == 3) {
        // TODO
      } else if (exposedHeightFill == 4) {
        var font = Gfx.FONT_XTINY;
        var fontHeight = Gfx.getFontHeight(font);

        drawHeightArrow(
          dc,
          x0,
          y0 + height / 2 - fontHeight - fontHeight / 2,
          fontHeight,
          width,
          BOTTOM,
          DOWN
        );
        drawHeightText(
          dc,
          x0,
          y0 + height / 2 - fontHeight / 2,
          fontHeight,
          width,
          CENTER,
          exposedHeight2 + "-" + exposedHeight1 + "m"
        );
        drawHeightArrow(
          dc,
          x0,
          y0 + height / 2 + fontHeight / 2,
          fontHeight,
          width,
          TOP,
          UP
        );
      }
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
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, width, height);
      }

      var font = Gfx.FONT_XTINY;
      var fontHeight = Gfx.getFontHeight(font);

      var textX0 = x0 + width / 2;

      var textY0 = 0;
      if (alignment == TOP) {
        textY0 = y0 + fontHeight / 2;
      } else if (alignment == CENTER) {
        textY0 = y0 + height / 2;
      } else if (alignment == BOTTOM) {
        textY0 = y0 + height - fontHeight / 2;
      }

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
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, width, height);
      }

      var font = Gfx.FONT_XTINY;
      var fontHeight = Gfx.getFontHeight(font);

      var arrowHeight = fontHeight;
      var arrowWidth = fontHeight * 0.66;

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
  }
}
