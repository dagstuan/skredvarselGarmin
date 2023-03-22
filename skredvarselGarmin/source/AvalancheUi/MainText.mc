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
    private const TICK_DURATION = 100;
    private const TICKS_AT_TOP_BOTTOM = 15;

    private var _text as String;
    private var _width as Numeric;
    private var _height as Numeric;

    private var _textOffset as Number = 0;
    private var _textHeight as Number?;

    private var _ticksAtTop = 0;
    private var _ticksAtBottom = 0;

    private var _bufferedBitmapText as Gfx.BufferedBitmap?;

    private var _updateTimer as Timer.Timer?;

    public function initialize(settings as MainTextSettings) {
      _text = settings[:text];
      _width = settings[:width];
      _height = settings[:height];
    }

    public function onShow() as Void {
      if (_textHeight > _height) {
        if (_updateTimer == null) {
          _updateTimer = new Timer.Timer();
        }

        _updateTimer.start(
          method(:triggerUpdate),
          TICK_DURATION /* ms */,
          false
        );
      }
    }

    public function onHide() as Void {
      if (_updateTimer != null) {
        _updateTimer.stop();
      }
      _updateTimer = null;
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

      if (_textHeight <= _height) {
        dc.drawBitmap(
          x0,
          y0 + _height / 2 - _textHeight / 2,
          _bufferedBitmapText
        );
      } else {
        dc.setClip(x0, y0, _width, _height);
        dc.drawBitmap(x0, y0 + _textOffset, _bufferedBitmapText);
        dc.clearClip();
      }
    }

    function triggerUpdate() as Void {
      var atBottom = _textOffset < _height - _textHeight;
      if (atBottom) {
        _ticksAtBottom += 1;
      } else if (_textOffset == 0 && _ticksAtTop < TICKS_AT_TOP_BOTTOM) {
        _ticksAtTop += 1;
      } else {
        _ticksAtTop = 0;
        _textOffset -= 1;
      }

      if (atBottom && _ticksAtBottom > TICKS_AT_TOP_BOTTOM) {
        _textOffset = 0;
        _ticksAtBottom = 0;
      }
      _updateTimer.start(method(:triggerUpdate), TICK_DURATION /* ms */, false);
      Ui.requestUpdate();
    }
  }
}
