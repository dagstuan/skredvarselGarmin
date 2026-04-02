import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.System;

module AvalancheUi {
  typedef ExposedHeightTextSettings as {
    :dc as Gfx.Dc,
    :exposedHeight1 as Number,
    :exposedHeight2 as Number,
    :exposedHeightFill as Number,
    :maxWidth as Numeric,
    :maxHeight as Numeric,
    :dangerFillColor as Gfx.ColorType,
  };

  public class ExposedHeightText {
    private const MS_AT_START_END = 2000;
    private const SCROLL_SPEED = 2;

    private var _exposedHeight1 as Number;
    private var _exposedHeight2 as Number;
    private var _exposedHeightFill as Number;
    private var _elementSpacing as Number = 4;

    private var _maxWidth as Number;
    private var _maxHeight as Number;
    private var _halfMaxHeight as Number;
    private var _width as Number;
    private var _textContainerWidth as Number;
    private var _showStartedMs as Number = 0;

    private var _font = Gfx.FONT_XTINY;
    private var _fontHeight as Number = Gfx.getFontHeight(_font);

    private var _arrowHeight as Numeric = _fontHeight;
    private var _arrowWidth as Numeric = _fontHeight * 0.66;

    private var _arrows as Array<AvalancheUi.Arrow?> = [];
    private var _texts as Array<Dictionary> = [];

    private var _dangerFillColor as Gfx.ColorType;

    public function initialize(settings as ExposedHeightTextSettings) {
      _exposedHeight1 = settings[:exposedHeight1];
      _exposedHeight2 = settings[:exposedHeight2];
      _exposedHeightFill = settings[:exposedHeightFill];
      _dangerFillColor = settings[:dangerFillColor];
      _maxWidth = settings[:maxWidth];
      _maxHeight = settings[:maxHeight];
      _halfMaxHeight = _maxHeight / 2;
      _textContainerWidth = getTextContainerWidth();

      setupElements(settings[:dc]);
      _width = getCalculatedWidth();
    }

    public function onShow() as Void {
      _showStartedMs = System.getTimer();
    }

    public function getWidth() {
      return _width;
    }

    private function getCalculatedWidth() as Numeric {
      if (_exposedHeightFill == 1 || _exposedHeightFill == 2) {
        return $.max([_arrows[0].getWidth(), _textContainerWidth]);
      } else if (_exposedHeightFill == 3) {
        return _arrowWidth + _elementSpacing + _textContainerWidth;
      } else if (_exposedHeightFill == 4) {
        return _arrowWidth + _elementSpacing + _textContainerWidth;
      }

      return 0;
    }

    private function setupElements(dc as Gfx.Dc) {
      if (_exposedHeightFill == 1) {
        _arrows = [createArrow(UP)];
        _texts = [
          createTextElement(
            dc,
            _maxWidth,
            _halfMaxHeight,
            Y_ALIGN_TOP,
            _exposedHeight1 + "m"
          ),
        ];
      } else if (_exposedHeightFill == 2) {
        _texts = [
          createTextElement(
            dc,
            _maxWidth,
            _halfMaxHeight,
            Y_ALIGN_BOTTOM,
            _exposedHeight1 + "m"
          ),
        ];
        _arrows = [createArrow(DOWN)];
      } else if (_exposedHeightFill == 3) {
        _arrows = [createArrow(UP), createArrow(DOWN)];
        var textWidth = _maxWidth - _arrowWidth - _elementSpacing;
        if (textWidth > _textContainerWidth) {
          textWidth = _textContainerWidth;
        }
        if (textWidth < 1) {
          textWidth = 1;
        }
        _texts = [
          createTextElement(
            dc,
            textWidth,
            _halfMaxHeight,
            Y_ALIGN_BOTTOM,
            _exposedHeight1 + "m"
          ),
          createTextElement(
            dc,
            textWidth,
            _halfMaxHeight,
            Y_ALIGN_TOP,
            _exposedHeight2 + "m"
          ),
        ];
      } else if (_exposedHeightFill == 4) {
        var text = Lang.format("$1$-$2$m", [_exposedHeight2, _exposedHeight1]);
        var textWidth = _textContainerWidth - _arrowWidth - _elementSpacing;
        if (textWidth < 1) {
          textWidth = 1;
        }

        _arrows = [createArrow(DOWN), createArrow(UP)];
        _texts = [
          createTextElement(dc, textWidth, _maxHeight, Y_ALIGN_CENTER, text),
        ];
      }
    }

    private function createArrow(direction as AvalancheUi.ArrowDirection) {
      return new AvalancheUi.Arrow({
        :width => _arrowWidth,
        :height => _arrowHeight,
        :color => _dangerFillColor,
        :direction => direction,
      });
    }

    private function createTextElement(
      dc as Gfx.Dc,
      containerWidth as Numeric,
      containerHeight as Numeric,
      yAlignment as TextElementsYAlignment,
      text as String
    ) {
      return {
        :text => text,
        :containerWidth => containerWidth,
        :containerHeight => containerHeight,
        :yAlignment => yAlignment,
        :textWidth => dc.getTextWidthInPixels(text, _font),
      };
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _width, _halfMaxHeight);
      }

      var bottomY0 = y0 + _halfMaxHeight;

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, bottomY0, _width, _halfMaxHeight);
      }

      if (_exposedHeightFill == 1) {
        var fill1TextWidth = getVisibleTextWidth(0);
        drawArrow(
          dc,
          0,
          x0 + fill1TextWidth / 2 - _arrowWidth / 2,
          y0,
          _halfMaxHeight,
          X_ALIGN_LEFT,
          Y_ALIGN_BOTTOM
        );
        drawTextElement(dc, 0, x0, bottomY0);
      } else if (_exposedHeightFill == 2) {
        var fill2TextWidth = getVisibleTextWidth(0);
        drawTextElement(dc, 0, x0, y0);
        drawArrow(
          dc,
          0,
          x0 + fill2TextWidth / 2 - _arrowWidth / 2,
          bottomY0,
          _halfMaxHeight,
          X_ALIGN_LEFT,
          Y_ALIGN_TOP
        );
      } else if (_exposedHeightFill == 3) {
        drawArrow(
          dc,
          0,
          x0,
          y0 - _elementSpacing / 2,
          _halfMaxHeight,
          X_ALIGN_LEFT,
          Y_ALIGN_BOTTOM
        );
        drawTextElement(
          dc,
          0,
          x0 + _arrowWidth + _elementSpacing,
          y0 - _elementSpacing / 2
        );
        drawArrow(
          dc,
          1,
          x0,
          bottomY0 + _elementSpacing / 2,
          _halfMaxHeight,
          X_ALIGN_LEFT,
          Y_ALIGN_TOP
        );
        drawTextElement(
          dc,
          1,
          x0 + _arrowWidth + _elementSpacing,
          bottomY0 + _elementSpacing / 2
        );
      } else if (_exposedHeightFill == 4) {
        drawArrow(
          dc,
          0,
          x0,
          y0 + _maxHeight / 2 - _arrowHeight,
          _fontHeight,
          X_ALIGN_LEFT,
          Y_ALIGN_TOP
        );
        drawTextElement(dc, 0, x0 + _arrowWidth + _elementSpacing, y0);
        drawArrow(
          dc,
          1,
          x0,
          y0 + _maxHeight / 2,
          _fontHeight,
          X_ALIGN_LEFT,
          Y_ALIGN_TOP
        );
      }
    }

    private function drawTextElement(
      dc as Gfx.Dc,
      textIndex as Number,
      x0 as Numeric,
      y0 as Numeric
    ) {
      var textElement = _texts[textIndex];
      var textWidth = textElement[:textWidth] as Number;
      var containerWidth = textElement[:containerWidth] as Number;
      var containerHeight = textElement[:containerHeight] as Number;
      var yAlignment = textElement[:yAlignment] as TextElementsYAlignment;
      var yOffset = 0;

      if (yAlignment == Y_ALIGN_CENTER) {
        yOffset = containerHeight / 2 - _fontHeight / 2;
      } else if (yAlignment == Y_ALIGN_BOTTOM) {
        yOffset = containerHeight - _fontHeight;
      }

      dc.setClip(x0, y0 + yOffset, containerWidth, _fontHeight);
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.drawText(
        x0 + getTextXOffset(textWidth, containerWidth),
        y0 + yOffset,
        _font,
        textElement[:text] as String,
        Gfx.TEXT_JUSTIFY_LEFT
      );
      dc.clearClip();
    }

    private function getTextContainerWidth() as Number {
      if (_exposedHeightFill == 3 || _exposedHeightFill == 4) {
        var availableWidth = _maxWidth - _arrowWidth - _elementSpacing;
        if (availableWidth > 0) {
          return availableWidth;
        }

        return 1;
      }

      return _maxWidth;
    }

    private function getVisibleTextWidth(index as Number) as Number {
      var textElement = _texts[index];
      var textWidth = textElement[:textWidth] as Number;
      var containerWidth = textElement[:containerWidth] as Number;

      return textWidth < containerWidth ? textWidth : containerWidth;
    }

    private function getTextXOffset(
      textWidth as Number,
      containerWidth as Number
    ) as Number {
      if (textWidth <= containerWidth) {
        return 0;
      }

      var now = System.getTimer();
      if (now < _showStartedMs) {
        _showStartedMs = now;
      }

      var overflow = textWidth - containerWidth;
      var scrollDurationMs = ((overflow * 100.0) / SCROLL_SPEED).toNumber();
      var cycleTicks = MS_AT_START_END + scrollDurationMs + MS_AT_START_END;
      var elapsedMs = (now - _showStartedMs) % cycleTicks;

      if (elapsedMs < MS_AT_START_END) {
        return 0;
      }

      if (elapsedMs < cycleTicks - MS_AT_START_END) {
        var endOffset = -overflow;
        var scrollElapsedMs = elapsedMs - MS_AT_START_END;
        var scrolled = -(
          (SCROLL_SPEED.toFloat() * scrollElapsedMs.toFloat()) /
          100.0
        ).toNumber();

        return scrolled < endOffset ? endOffset : scrolled;
      }

      return -overflow;
    }

    private function drawArrow(
      dc as Gfx.Dc,
      arrowIndex as Number,
      x0 as Numeric,
      y0 as Numeric,
      containerHeight as Numeric,
      xAlignment as TextElementsXAlignment,
      yAlignment as TextElementsYAlignment
    ) {
      var arrowXOffset = 0;
      if (xAlignment == X_ALIGN_CENTER) {
        arrowXOffset = _width / 2 - _arrowWidth / 2;
      }

      var arrowYOffset =
        yAlignment == Y_ALIGN_TOP ? 0 : containerHeight - _arrowHeight;
      _arrows[arrowIndex].draw(dc, x0 + arrowXOffset, y0 + arrowYOffset);
    }
  }
}
