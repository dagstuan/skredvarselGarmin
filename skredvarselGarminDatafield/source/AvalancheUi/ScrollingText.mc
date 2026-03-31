import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.System;

module AvalancheUi {
  var ScrollingTextStartTimeMs as Number? = null;

  public function tickScrollingTexts() as Void {
    if (ScrollingTextStartTimeMs == null) {
      resetScrollingTexts();
    }
  }

  public function resetScrollingTexts() as Void {
    ScrollingTextStartTimeMs = System.getTimer();
  }

  function getScrollingTextElapsedMs() as Number {
    if (ScrollingTextStartTimeMs == null) {
      resetScrollingTexts();
      return 0;
    }

    var now = System.getTimer();
    if (now < (ScrollingTextStartTimeMs as Number)) {
      ScrollingTextStartTimeMs = now;
      return 0;
    }

    return now - (ScrollingTextStartTimeMs as Number);
  }

  public enum ScrollingTextDirection {
    SCROLL_DIRECTION_HORIZONTAL = 0,
    SCROLL_DIRECTION_VERTICAL = 1,
  }

  typedef ScrollingTextSettings as {
    :dc as Gfx.Dc,
    :text as String,
    :containerWidth as Numeric,
    :containerHeight as Numeric,
    :scrollDirection as ScrollingTextDirection?,
    :scrollSpeed as Numeric?,
    :xAlignment as TextElementsXAlignment?,
    :yAlignment as TextElementsYAlignment?,
    :font as Gfx.FontType,
    :color as Gfx.ColorValue?,
    :backgroundColor as Gfx.ColorValue?,
  };

  public class ScrollingText {
    private const MS_AT_START_END = 2000;

    private var _text as String;
    private var _containerWidth as Numeric;
    private var _containerHeight as Numeric;

    private var _font as Gfx.FontType;
    private var _fontHeight as Number;

    private var _color as Gfx.ColorValue;
    private var _backgroundColor as Gfx.ColorValue;

    private var _scrollDirection as ScrollingTextDirection;

    private var _textXAlignment as TextElementsXAlignment;
    private var _horizontalTextYOffset as Numeric = 0.0;

    private var _textOffset as Numeric = 0.0;
    private var _textWidth as Number?;
    private var _textHeight as Number?;

    // Total cycle length in ms: start pause + scroll duration + end pause.
    private var _cycleTicks as Number = 0;

    private var _speed;

    private var _bufferedBitmapText as Gfx.BufferedBitmap?;

    public function initialize(settings as ScrollingTextSettings) {
      _text = settings[:text];
      _containerWidth = settings[:containerWidth];
      _containerHeight = settings[:containerHeight];
      _font = settings[:font];
      _fontHeight = Gfx.getFontHeight(_font);

      _color = settings[:color] != null ? settings[:color] : Gfx.COLOR_WHITE;

      _speed = settings[:scrollSpeed] != null ? settings[:scrollSpeed] : 2;

      _backgroundColor =
        settings[:backgroundColor] != null
          ? settings[:backgroundColor]
          : Gfx.COLOR_TRANSPARENT;

      _scrollDirection =
        settings[:scrollDirection] != null
          ? settings[:scrollDirection]
          : SCROLL_DIRECTION_HORIZONTAL;

      _textXAlignment =
        settings[:xAlignment] != null ? settings[:xAlignment] : X_ALIGN_CENTER;

      var horizontalTextYAlignment =
        settings[:yAlignment] != null ? settings[:yAlignment] : Y_ALIGN_CENTER;
      if (horizontalTextYAlignment == Y_ALIGN_CENTER) {
        _horizontalTextYOffset = _containerHeight / 2.0 - _fontHeight / 2.0;
      } else if (horizontalTextYAlignment == Y_ALIGN_BOTTOM) {
        _horizontalTextYOffset = _containerHeight - _fontHeight;
      }

      setupBitmap(settings[:dc]);
    }

    public function onShow() as Void {}

    public function getCycleTicks() as Number {
      return _cycleTicks;
    }

    public function setCycleTicks(cycleTicks as Number) as Void {
      _cycleTicks = cycleTicks;
    }

    public function getWidth() {
      return $.min(_textWidth, _containerWidth);
    }

    private function setupBitmap(dc as Gfx.Dc) {
      if (_scrollDirection == SCROLL_DIRECTION_HORIZONTAL) {
        setupHorizontal(dc);
      } else {
        setupVertical(dc);
      }
    }

    private function setupHorizontal(dc as Gfx.Dc) {
      _textWidth = dc.getTextWidthInPixels(_text, _font);

      _bufferedBitmapText = $.newBufferedBitmap({
        :width => _textWidth,
        :height => _fontHeight,
      });
      var bufferedDc = _bufferedBitmapText.getDc();

      if (bufferedDc has :setAntiAlias) {
        bufferedDc.setAntiAlias(true);
      }

      bufferedDc.setColor(_color, _backgroundColor);
      bufferedDc.drawText(0, 0, _font, _text, Gfx.TEXT_JUSTIFY_LEFT);

      if (_textWidth > _containerWidth) {
        var scrollDurationMs = Math.ceil(
          ((_textWidth - _containerWidth).toFloat() * 100.0) / _speed.toFloat()
        ).toNumber();
        _cycleTicks = MS_AT_START_END + scrollDurationMs + MS_AT_START_END;
      }
    }

    private function setupVertical(dc as Gfx.Dc) {
      var fitText = Gfx.fitTextToArea(
        _text,
        _font,
        _containerWidth,
        _containerHeight * 10,
        true
      );

      var fitTextDimensions = dc.getTextDimensions(fitText, _font);
      _textWidth = fitTextDimensions[0];
      _textHeight = fitTextDimensions[1];

      _bufferedBitmapText = $.newBufferedBitmap({
        :width => _containerWidth,
        :height => _textHeight,
      });

      var bufferedDc = _bufferedBitmapText.getDc();

      if (bufferedDc has :setAntiAlias) {
        bufferedDc.setAntiAlias(true);
      }

      bufferedDc.setColor(_color, _backgroundColor);

      if (_textHeight <= _containerHeight) {
        bufferedDc.drawText(
          _containerWidth / 2,
          _textHeight / 2,
          _font,
          fitText,
          Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
      } else {
        bufferedDc.drawText(
          _containerWidth / 2,
          0,
          _font,
          fitText,
          Gfx.TEXT_JUSTIFY_CENTER
        );
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      calcTextOffset();

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _containerWidth, _containerHeight);
      }

      if (_scrollDirection == SCROLL_DIRECTION_HORIZONTAL) {
        drawHorizontal(dc, x0, y0);
      } else {
        drawVertical(dc, x0, y0);
      }
    }

    public function drawHorizontal(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) as Void {
      if (_textWidth > _containerWidth) {
        dc.setClip(
          x0,
          y0 + _horizontalTextYOffset,
          _containerWidth,
          _fontHeight
        );
        dc.drawBitmap(
          x0 + _textOffset,
          y0 + _horizontalTextYOffset,
          _bufferedBitmapText
        );
        dc.clearClip();
      } else {
        var xOffset =
          _textXAlignment == X_ALIGN_CENTER
            ? _containerWidth / 2 - _textWidth / 2
            : 0;

        dc.drawBitmap(
          x0 + xOffset,
          y0 + _horizontalTextYOffset,
          _bufferedBitmapText
        );
      }
    }

    public function drawVertical(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) as Void {
      if (_textHeight > _containerHeight) {
        dc.setClip(x0, y0, _containerWidth, _containerHeight);
        dc.drawBitmap(x0, y0 + _textOffset, _bufferedBitmapText);
        dc.clearClip();
      } else {
        dc.drawBitmap(
          x0,
          y0 + _containerHeight / 2 - _textHeight / 2,
          _bufferedBitmapText
        );
      }
    }

    function calcTextOffset() as Void {
      if (_cycleTicks == 0) {
        return;
      }
      var elapsedMs = AvalancheUi.getScrollingTextElapsedMs() % _cycleTicks;
      if (elapsedMs < MS_AT_START_END) {
        _textOffset = 0;
      } else if (elapsedMs < _cycleTicks - MS_AT_START_END) {
        var endOffset = _containerWidth - _textWidth;
        var scrollElapsedMs = elapsedMs - MS_AT_START_END;
        var scrolled = -(
          (_speed.toFloat() * scrollElapsedMs.toFloat()) /
          100.0
        );
        _textOffset = scrolled < endOffset ? endOffset : scrolled;
      } else {
        _textOffset = _containerWidth - _textWidth;
      }
    }
  }
}
