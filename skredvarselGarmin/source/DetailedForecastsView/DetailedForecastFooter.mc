import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Time;

typedef DetailedForecastFooterSettings as {
  :regionName as String,
  :fetchedTime as Time.Moment,
  :locX as Numeric,
  :locY as Numeric,
  :width as Numeric,
  :height as Numeric,
};

public class DetailedForecastFooter {
  private const TICKS_AT_START_END = 30;

  private var _regionName as String;
  private var _fetchedTime as Time.Moment;
  private var _locX as Numeric;
  private var _locY as Numeric;
  private var _width as Numeric;
  private var _height as Numeric;

  private var _font = Gfx.FONT_XTINY;
  private var _fontHeight as Number;

  private var _textOffset as Numeric = 0.0;
  private var _ticksAtStart = 0;
  private var _ticksAtEnd = 0;
  private var _dir = 1;

  private var _bufferedBitmapText as Gfx.BufferedBitmap?;
  private var _bufferedBitmapWidth as Numeric?;
  private var _bufferedBitmapHeight as Numeric?;

  public function initialize(settings as DetailedForecastFooterSettings) {
    _regionName = settings[:regionName];
    _fetchedTime = settings[:fetchedTime];
    _locX = settings[:locX];
    _locY = settings[:locY];
    _width = settings[:width];
    _height = settings[:height];

    _fontHeight = Gfx.getFontHeight(_font);
  }

  public function draw(dc as Gfx.Dc) {
    if (_bufferedBitmapText == null) {
      var updatedString = $.getOrLoadResourceString("Oppdatert", :Updated);
      var text =
        _regionName +
        "\n" +
        updatedString +
        " " +
        $.getFormattedTimestamp(_fetchedTime);

      var textDimensions = dc.getTextDimensions(text, _font);

      _bufferedBitmapWidth = textDimensions[0];
      _bufferedBitmapHeight = textDimensions[1];

      _bufferedBitmapText = $.newBufferedBitmap({
        :width => _bufferedBitmapWidth,
        :height => _bufferedBitmapHeight,
      });
      var bufferedDc = _bufferedBitmapText.getDc();
      bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

      bufferedDc.drawText(
        textDimensions[0] / 2,
        textDimensions[1] / 2,
        _font,
        text,
        Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
      );
    }

    var textX0 = _locX + _width / 2 - _bufferedBitmapWidth / 2;
    var textY0 = _locY + _height / 2 - _fontHeight / 2;

    calcTextOffset();

    dc.setClip(textX0, textY0, _width, _fontHeight);
    dc.drawBitmap(textX0, textY0 - _textOffset, _bufferedBitmapText);
    dc.clearClip();
  }

  function calcTextOffset() as Void {
    var atEnd = _textOffset > _bufferedBitmapHeight - _fontHeight;
    var atStart = _textOffset == 0;

    if (atEnd && _ticksAtEnd < TICKS_AT_START_END) {
      _ticksAtEnd += 1;
    } else if (atStart && _ticksAtStart < TICKS_AT_START_END) {
      _ticksAtStart += 1;
    } else {
      if (atEnd) {
        _ticksAtEnd = 0;
        _dir = -1;
      } else if (atStart) {
        _ticksAtStart = 0;
        _dir = 1;
      }

      _textOffset += _dir * 1.25;
    }
  }
}
