import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  public enum ScrollingTextDirection {
    SCROLL_DIRECTION_HORIZONTAL = 0,
    SCROLL_DIRECTION_VERTICAL = 1,
  }

  typedef ScrollingTextSettings as {
    :text as String,
    :containerWidth as Numeric,
    :containerHeight as Numeric,
    :scrollDirection as ScrollingTextDirection?,
    :xAlignment as TextElementsXAlignment?,
    :yAlignment as TextElementsYAlignment?,
    :font as Gfx.FontType,
    :color as Gfx.ColorValue?,
    :backgroundColor as Gfx.ColorValue?,
  };

  public class ScrollingText {
    private const TICKS_AT_START_END = 20;

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

    private var _ticksAtStart = 0;
    private var _ticksAtEnd = 0;

    private var _bufferedBitmapText as Gfx.BufferedBitmap?;

    private var _isVisible as Boolean;

    public function initialize(settings as ScrollingTextSettings) {
      _text = settings[:text];
      _containerWidth = settings[:containerWidth];
      _containerHeight = settings[:containerHeight];
      _font = settings[:font];
      _fontHeight = Gfx.getFontHeight(_font);

      _color = settings[:color] != null ? settings[:color] : Gfx.COLOR_WHITE;

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

      _isVisible = false;
    }

    public function onShow() as Void {
      _isVisible = true;
    }

    public function onHide() as Void {
      _isVisible = false;
    }

    public function onTick() as Void {
      if (_isVisible) {
        calcTextOffset();
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
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
      if (_bufferedBitmapText == null) {
        _textWidth = dc.getTextWidthInPixels(_text, _font);

        _bufferedBitmapText = $.newBufferedBitmap({
          :width => _textWidth,
          :height => _fontHeight,
        });
        var bufferedDc = _bufferedBitmapText.getDc();

        bufferedDc.setAntiAlias(true);
        bufferedDc.setColor(_color, _backgroundColor);
        bufferedDc.drawText(0, 0, _font, _text, Gfx.TEXT_JUSTIFY_LEFT);
      }

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
      if (_bufferedBitmapText == null) {
        var fitText = Gfx.fitTextToArea(
          _text,
          _font,
          _containerWidth,
          _containerHeight * 5,
          false
        );

        var fitTextDimensions = dc.getTextDimensions(fitText, _font);
        _textHeight = fitTextDimensions[1];

        _bufferedBitmapText = $.newBufferedBitmap({
          :width => _containerWidth,
          :height => _textHeight,
        });

        var bufferedDc = _bufferedBitmapText.getDc();

        bufferedDc.setAntiAlias(true);
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
      var atEnd =
        _scrollDirection == SCROLL_DIRECTION_HORIZONTAL
          ? _textOffset < _containerWidth - _textWidth
          : _textOffset < _containerHeight - _textHeight;
      if (atEnd) {
        _ticksAtEnd += 1;
      } else if (_textOffset == 0 && _ticksAtStart < TICKS_AT_START_END) {
        _ticksAtStart += 1;
      } else {
        _ticksAtStart = 0;
        _textOffset -= 1;
      }

      if (atEnd && _ticksAtEnd > TICKS_AT_START_END) {
        _textOffset = 0;
        _ticksAtEnd = 0;
      }
    }
  }
}
