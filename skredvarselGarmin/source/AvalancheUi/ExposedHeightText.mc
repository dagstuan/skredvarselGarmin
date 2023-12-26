import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  public enum TextElementsYAlignment {
    Y_ALIGN_TOP = 0,
    Y_ALIGN_BOTTOM = 1,
    Y_ALIGN_CENTER = 2,
  }

  public enum TextElementsXAlignment {
    X_ALIGN_LEFT = 0,
    X_ALIGN_CENTER = 2,
  }

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
    private var _exposedHeight1 as Number;
    private var _exposedHeight2 as Number;
    private var _exposedHeightFill as Number;
    private var _elementSpacing as Number = 4;

    private var _maxWidth as Number;
    private var _maxHeight as Number;
    private var _halfMaxHeight as Number;
    private var _width as Number;

    private var _font = Gfx.FONT_XTINY;
    private var _fontHeight as Number = Gfx.getFontHeight(_font);

    private var _arrowHeight as Numeric = _fontHeight;
    private var _arrowWidth as Numeric = _fontHeight * 0.66;

    private var _arrows as Array<AvalancheUi.Arrow?> = [];
    private var _scrollingTexts as Array<AvalancheUi.ScrollingText?> = [];

    private var _dangerFillColor as Gfx.ColorType;

    public function initialize(settings as ExposedHeightTextSettings) {
      _exposedHeight1 = settings[:exposedHeight1];
      _exposedHeight2 = settings[:exposedHeight2];
      _exposedHeightFill = settings[:exposedHeightFill];
      _dangerFillColor = settings[:dangerFillColor];
      _maxWidth = settings[:maxWidth];
      _maxHeight = settings[:maxHeight];
      _halfMaxHeight = _maxHeight / 2;

      setupElements(settings[:dc]);
      _width = getCalculatedWidth();
    }

    public function onShow() as Void {
      for (var i = 0; i < _scrollingTexts.size(); i++) {
        if (_scrollingTexts[i] != null) {
          _scrollingTexts[i].onShow();
        }
      }
    }

    public function onHide() as Void {
      for (var i = 0; i < _scrollingTexts.size(); i++) {
        if (_scrollingTexts[i] != null) {
          _scrollingTexts[i].onHide();
        }
      }
    }

    public function onTick() as Void {
      for (var i = 0; i < _scrollingTexts.size(); i++) {
        if (_scrollingTexts[i] != null) {
          _scrollingTexts[i].onTick();
        }
      }
    }

    public function getWidth() {
      return _width;
    }

    private function getCalculatedWidth() as Numeric {
      if (_exposedHeightFill == 1 || _exposedHeightFill == 2) {
        return $.max([_arrows[0].getWidth(), _scrollingTexts[0].getWidth()]);
      } else if (_exposedHeightFill == 3) {
        return $.max([
          _arrows[0].getWidth() +
            _elementSpacing +
            _scrollingTexts[0].getWidth(),
          _arrows[1].getWidth() +
            _elementSpacing +
            _scrollingTexts[1].getWidth(),
        ]);
      } else if (_exposedHeightFill == 4) {
        return $.max([
          _arrows[0].getWidth(),
          _scrollingTexts[0].getWidth(),
          _arrows[1].getWidth(),
        ]);
      }

      return 0;
    }

    private function setupElements(dc as Gfx.Dc) {
      if (_exposedHeightFill == 1) {
        _arrows = [createArrow(UP)];
        _scrollingTexts = [
          createScrollingText(
            dc,
            _maxWidth,
            _halfMaxHeight,
            Y_ALIGN_TOP,
            _exposedHeight1 + "m"
          ),
        ];
      } else if (_exposedHeightFill == 2) {
        _scrollingTexts = [
          createScrollingText(
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
        _scrollingTexts = [
          createScrollingText(
            dc,
            _maxWidth - _arrowWidth - _elementSpacing,
            _halfMaxHeight,
            Y_ALIGN_BOTTOM,
            _exposedHeight1 + "m"
          ),
          createScrollingText(
            dc,
            _maxWidth - _arrowWidth - _elementSpacing,
            _halfMaxHeight,
            Y_ALIGN_TOP,
            _exposedHeight2 + "m"
          ),
        ];
      } else if (_exposedHeightFill == 4) {
        var text = Lang.format("$1$-$2$m", [_exposedHeight2, _exposedHeight1]);

        _arrows = [createArrow(DOWN), createArrow(UP)];
        _scrollingTexts = [
          createScrollingText(dc, _maxWidth, _fontHeight, Y_ALIGN_CENTER, text),
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

    private function createScrollingText(
      dc as Gfx.Dc,
      containerWidth as Numeric,
      containerHeight as Numeric,
      yAlignment as TextElementsYAlignment,
      text as String
    ) {
      return new ScrollingText({
        :dc => dc,
        :text => text,
        :containerWidth => containerWidth,
        :containerHeight => containerHeight,
        :xAlignment => X_ALIGN_LEFT,
        :yAlignment => yAlignment,
        :font => _font,
      });
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
        drawArrow(
          dc,
          0,
          x0,
          y0,
          _halfMaxHeight,
          X_ALIGN_CENTER,
          Y_ALIGN_BOTTOM
        );
        drawScrollingText(dc, 0, x0, bottomY0);
      } else if (_exposedHeightFill == 2) {
        drawScrollingText(dc, 0, x0, y0);
        drawArrow(
          dc,
          0,
          x0,
          bottomY0,
          _halfMaxHeight,
          X_ALIGN_CENTER,
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
        drawScrollingText(
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
        drawScrollingText(
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
          y0 + _maxHeight / 2 - _fontHeight - _fontHeight / 2,
          _fontHeight,
          X_ALIGN_CENTER,
          Y_ALIGN_BOTTOM
        );
        drawScrollingText(dc, 0, x0, y0 + _maxHeight / 2 - _fontHeight / 2);
        drawArrow(
          dc,
          1,
          x0,
          y0 + _maxHeight / 2 + _fontHeight / 2,
          _fontHeight,
          X_ALIGN_CENTER,
          Y_ALIGN_TOP
        );
      }
    }

    private function drawScrollingText(
      dc as Gfx.Dc,
      textIndex as Number,
      x0 as Numeric,
      y0 as Numeric
    ) {
      _scrollingTexts[textIndex].draw(dc, x0, y0);
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
