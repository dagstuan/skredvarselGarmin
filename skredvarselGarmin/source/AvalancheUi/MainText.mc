import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.WatchUi as Ui;
using Toybox.Timer;

module AvalancheUi {
  typedef MainTextSettings as {
    :text as String,
    :width as Numeric,
    :height as Numeric,
  };

  class MainText {
    private const TICKS_AT_TOP_BOTTOM = 30;

    private var _text as String;
    private var _width as Numeric;
    private var _height as Numeric;

    private var _textOffset as Numeric = 0.0;
    private var _textHeight as Number?;

    private var _ticksAtTop = 0;
    private var _ticksAtBottom = 0;

    private var _bufferedBitmapText as Gfx.BufferedBitmap?;

    private var _isVisible as Boolean;

    public function initialize(settings as MainTextSettings) {
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

    public function onTick() as Void {
      if (_isVisible) {
        calcTextOffset();
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      if (_bufferedBitmapText == null) {
        var font = Gfx.FONT_SYSTEM_XTINY;

        var fitText = Gfx.fitTextToArea(
          _text,
          font,
          _width,
          _height * 5,
          false
        );

        var fitTextDimensions = dc.getTextDimensions(fitText, font);
        _textHeight = fitTextDimensions[1];

        _bufferedBitmapText = $.newBufferedBitmap({
          :width => _width,
          :height => _textHeight,
        });

        var bufferedDc = _bufferedBitmapText.getDc();

        bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        if (_textHeight <= _height) {
          bufferedDc.drawText(
            _width / 2,
            _textHeight / 2,
            font,
            fitText,
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
          );
        } else {
          bufferedDc.drawText(
            _width / 2,
            0,
            font,
            fitText,
            Gfx.TEXT_JUSTIFY_CENTER
          );
        }
      }

      if (_textHeight > _height) {
        dc.setClip(x0, y0, _width, _height);
        dc.drawBitmap(x0, y0 + _textOffset, _bufferedBitmapText);
        dc.clearClip();
      } else {
        dc.drawBitmap(
          x0,
          y0 + _height / 2 - _textHeight / 2,
          _bufferedBitmapText
        );
      }
    }

    function calcTextOffset() as Void {
      var atBottom = _textOffset < _height - _textHeight;
      if (atBottom) {
        _ticksAtBottom += 1;
      } else if (_textOffset == 0 && _ticksAtTop < TICKS_AT_TOP_BOTTOM) {
        _ticksAtTop += 1;
      } else {
        _ticksAtTop = 0;
        _textOffset -= 0.8; // bump size determines speed
      }

      if (atBottom && _ticksAtBottom > TICKS_AT_TOP_BOTTOM) {
        _textOffset = 0;
        _ticksAtBottom = 0;
      }
    }
  }
}
