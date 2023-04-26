import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  typedef ScrollingTextSettings as {
    :text as String,
    :containerWidth as Numeric,
    :containerHeight as Numeric,
    :xAlignment as TextElementsXAlignment?,
    :yAlignment as TextElementsYAlignment?,
    :font as Gfx.FontType,
  };

  public class ScrollingText {
    private const TICKS_AT_START_END = 20;

    private var _text as String;
    private var _containerWidth as Numeric;
    private var _containerHeight as Numeric;

    private var _font as Gfx.FontType;
    private var _fontHeight as Number;

    private var _textAnimationXOffset as Numeric = 0.0;
    private var _textXAlignment as TextElementsXAlignment;
    private var _textYOffset as Numeric;

    private var _textWidth as Number?;

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

      _textXAlignment = settings[:xAlignment];
      if (_textXAlignment == null) {
        _textXAlignment = X_ALIGN_CENTER;
      }

      var yAlignment = settings[:yAlignment];
      if (yAlignment == null) {
        yAlignment = Y_ALIGN_CENTER;
      }

      _textYOffset = 0; // 0 offset if at top.
      if (yAlignment == Y_ALIGN_CENTER) {
        _textYOffset = _containerHeight / 2.0 - _fontHeight / 2.0;
      } else if (yAlignment == Y_ALIGN_BOTTOM) {
        _textYOffset = _containerHeight - _fontHeight;
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
      if (_bufferedBitmapText == null) {
        _textWidth = dc.getTextWidthInPixels(_text, _font);

        _bufferedBitmapText = $.newBufferedBitmap({
          :width => _textWidth,
          :height => _fontHeight,
        });
        var bufferedDc = _bufferedBitmapText.getDc();

        bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        bufferedDc.drawText(0, 0, _font, _text, Gfx.TEXT_JUSTIFY_LEFT);
      }

      if (_textWidth > _containerWidth) {
        dc.setClip(x0, y0 + _textYOffset, _containerWidth, _fontHeight);
        dc.drawBitmap(
          x0 + _textAnimationXOffset,
          y0 + _textYOffset,
          _bufferedBitmapText
        );
        dc.clearClip();
      } else {
        var xOffset =
          _textXAlignment == X_ALIGN_CENTER
            ? _containerWidth / 2 - _textWidth / 2
            : 0;

        dc.drawBitmap(x0 + xOffset, y0 + _textYOffset, _bufferedBitmapText);
      }
    }

    function calcTextOffset() as Void {
      var atEnd = _textAnimationXOffset < _containerWidth - _textWidth;
      if (atEnd) {
        _ticksAtEnd += 1;
      } else if (
        _textAnimationXOffset == 0 &&
        _ticksAtStart < TICKS_AT_START_END
      ) {
        _ticksAtStart += 1;
      } else {
        _ticksAtStart = 0;
        _textAnimationXOffset -= 1.25;
      }

      if (atEnd && _ticksAtEnd > TICKS_AT_START_END) {
        _textAnimationXOffset = 0;
        _ticksAtEnd = 0;
      }
    }
  }
}
