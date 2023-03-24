import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Timer;

module AvalancheUi {
  typedef ScrollingTextSettings as {
    :text as String,
    :width as Numeric,
    :height as Numeric,
  };

  public class ScrollingText {
    private const TICKS_AT_START_END = 40;

    private var _text as String;
    private var _width as Numeric;
    private var _height as Numeric;

    private var _textOffset as Numeric = 0.0;

    private var _textWidth as Number?;

    private var _ticksAtStart = 0;
    private var _ticksAtEnd = 0;

    private var _bufferedBitmapText as Gfx.BufferedBitmap?;

    private var _isVisible as Boolean;

    public function initialize(settings as ScrollingTextSettings) {
      _text = settings[:text];
      _width = settings[:width];
      _height = settings[:height];
      _isVisible = false;
    }

    public function onShow() as Void {
      _isVisible = true;
    }

    public function onHide() as Void {
      _isVisible = false;
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      if (_bufferedBitmapText == null) {
        var font = Gfx.FONT_XTINY;
        var fontHeight = Gfx.getFontHeight(font);

        _textWidth = dc.getTextWidthInPixels(_text, font);

        _bufferedBitmapText = $.newBufferedBitmap({
          :width => _textWidth,
          :height => _height,
        });
        var bufferedDc = _bufferedBitmapText.getDc();

        bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        bufferedDc.drawText(
          0,
          _height / 2 - fontHeight / 2,
          font,
          _text,
          Gfx.TEXT_JUSTIFY_LEFT
        );
      }

      if (_textWidth > _width) {
        if (_isVisible) {
          calcTextOffset();
        }

        dc.setClip(x0, y0, _width, _height);
        dc.drawBitmap(x0 + _textOffset, y0, _bufferedBitmapText);
        dc.clearClip();
      } else {
        dc.drawBitmap(
          x0 + _width / 2 - _textWidth / 2,
          y0,
          _bufferedBitmapText
        );
      }
    }

    function calcTextOffset() as Void {
      var atEnd = _textOffset < _width - _textWidth;
      if (atEnd) {
        _ticksAtEnd += 1;
      } else if (_textOffset == 0 && _ticksAtStart < TICKS_AT_START_END) {
        _ticksAtStart += 1;
      } else {
        _ticksAtStart = 0;
        _textOffset -= 0.5;
      }

      if (atEnd && _ticksAtEnd > TICKS_AT_START_END) {
        _textOffset = 0;
        _ticksAtEnd = 0;
      }
    }
  }
}
