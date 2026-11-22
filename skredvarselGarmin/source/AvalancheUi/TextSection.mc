import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  // [header, text]
  typedef TextSectionPart as [String, String];

  typedef TextSectionSettings as {
    :dc as Gfx.Dc,
    :title as String,
    :parts as Array<TextSectionPart>,
    :width as Numeric,
    :height as Numeric,
  };

  // Auto scrolling parts, each with a header and a text. The title is joined
  // with each header ("Fjellvær, i dag") to save space, and scrolls with the
  // text. Unlike ScrollingText, the text is drawn directly instead of
  // through a buffered bitmap, since long texts would need a bitmap too large
  // for the memory on older watches.
  (:noLimitedBackgroundMemory)
  class TextSection {
    private const TICKS_AT_START_END = 20;
    private const SCROLL_SPEED = 2;

    private var _width as Numeric;
    private var _height as Numeric;

    private var _titleFont = Gfx.FONT_XTINY;
    private var _textFont = Gfx.FONT_SYSTEM_XTINY;

    // [header, fitted text, header height, text height]
    private var _parts as Array<[String, String, Number, Number]> = [];

    private var _titleLineHeight as Numeric;
    private var _partGap as Numeric;
    private var _contentHeight as Numeric = 0;

    private var _contentOffset as Numeric = 0;
    private var _ticksAtStart = 0;
    private var _ticksAtEnd = 0;
    private var _isVisible = false;

    public function initialize(settings as TextSectionSettings) {
      var dc = settings[:dc];
      var height = settings[:height];

      _width = settings[:width];
      _height = height;

      _titleLineHeight = Gfx.getFontHeight(_titleFont);
      _partGap = _titleLineHeight * 0.5;

      var parts = settings[:parts];
      for (var i = 0; i < parts.size(); i++) {
        var header = settings[:title] + ", " + parts[i][0].toLower();
        var headerHeight = _titleLineHeight;
        if (dc.getTextWidthInPixels(header, _titleFont) > _width) {
          // Too long for one line on narrow screens.
          header = settings[:title] + "\n" + parts[i][0];
          headerHeight = _titleLineHeight * 2;
        }

        var text = Gfx.fitTextToArea(
          parts[i][1],
          _textFont,
          _width,
          _height * 10,
          true
        );
        var textHeight = dc.getTextDimensions(text, _textFont)[1];
        _parts.add([header, text, headerHeight, textHeight]);

        if (i > 0) {
          _contentHeight += _partGap;
        }
        _contentHeight += headerHeight + textHeight;
      }
    }

    public function onShow() as Void {
      _contentOffset = 0;
      _ticksAtStart = 0;
      _ticksAtEnd = 0;
      _isVisible = true;
    }

    public function onHide() as Void {
      _isVisible = false;
    }

    public function onTick() as Void {
      if (!_isVisible || _contentHeight <= _height) {
        return;
      }

      var atEnd = _contentOffset < _height - _contentHeight;
      if (atEnd) {
        _ticksAtEnd += 1;
      } else if (_contentOffset == 0 && _ticksAtStart < TICKS_AT_START_END) {
        _ticksAtStart += 1;
      } else {
        _ticksAtStart = 0;
        _contentOffset -= SCROLL_SPEED;
      }

      if (atEnd && _ticksAtEnd > TICKS_AT_START_END) {
        _contentOffset = 0;
        _ticksAtEnd = 0;
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      // Skip drawing pages that are outside the screen.
      if (x0 >= dc.getWidth() || x0 + _width <= 0) {
        return;
      }

      var centerX = x0 + _width / 2;
      var y1 = y0 + _height;

      var partY0 = y0 + _contentOffset;
      if (_contentHeight <= _height) {
        partY0 = y0 + _height / 2 - _contentHeight / 2;
      }

      dc.setClip(x0, y0, _width, _height);
      for (var i = 0; i < _parts.size(); i++) {
        var part = _parts[i];
        var partY1 = partY0 + part[2] + part[3];

        // Skip parts scrolled outside the content area.
        if (partY1 > y0 && partY0 < y1) {
          dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
          dc.drawText(
            centerX,
            partY0,
            _titleFont,
            part[0],
            Gfx.TEXT_JUSTIFY_CENTER
          );

          dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
          dc.drawText(
            centerX,
            partY0 + part[2],
            _textFont,
            part[1],
            Gfx.TEXT_JUSTIFY_CENTER
          );
        }

        partY0 = partY1 + _partGap;
      }
      dc.clearClip();
    }
  }
}
