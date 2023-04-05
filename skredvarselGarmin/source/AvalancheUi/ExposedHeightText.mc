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
    :exposedHeight1 as Number,
    :exposedHeight2 as Number,
    :exposedHeightFill as Number,
    :width as Numeric,
    :height as Numeric,
    :dangerFillColor as Gfx.ColorType,
  };

  public class ExposedHeightText {
    private var _exposedHeight1 as Number;
    private var _exposedHeight2 as Number;
    private var _exposedHeightFill as Number;

    private var _width as Number;
    private var _height as Number;
    private var _halfHeight as Number;

    private var _font = Gfx.FONT_XTINY;
    private var _fontHeight as Number;

    private var _arrowHeight as Numeric;
    private var _arrowWidth as Numeric;

    private var _arrows as Array<AvalancheUi.Arrow?>;
    private var _scrollingTexts as Array<AvalancheUi.ScrollingText?>;

    private var _dangerFillColor as Gfx.ColorType;

    public function initialize(settings as ExposedHeightTextSettings) {
      _exposedHeight1 = settings[:exposedHeight1];
      _exposedHeight2 = settings[:exposedHeight2];
      _exposedHeightFill = settings[:exposedHeightFill];
      _dangerFillColor = settings[:dangerFillColor];
      _width = settings[:width];
      _height = settings[:height];

      _arrows = new [2];
      _scrollingTexts = new [2];

      _halfHeight = _height / 2;

      _fontHeight = Gfx.getFontHeight(_font);

      _arrowHeight = _fontHeight;
      _arrowWidth = _fontHeight * 0.66;
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

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _width, _halfHeight);
      }

      var bottomY0 = y0 + _halfHeight;

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, bottomY0, _width, _halfHeight);
      }

      if (_exposedHeightFill == 1) {
        drawArrow(
          dc,
          0,
          x0,
          y0,
          _halfHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_BOTTOM,
          UP
        );
        drawScrollingText(
          dc,
          0,
          x0,
          bottomY0,
          _halfHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_TOP,
          _exposedHeight1 + "m"
        );
      } else if (_exposedHeightFill == 2) {
        drawScrollingText(
          dc,
          0,
          x0,
          y0,
          _halfHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_BOTTOM,
          _exposedHeight1 + "m"
        );
        drawArrow(
          dc,
          0,
          x0,
          bottomY0,
          _halfHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_TOP,
          DOWN
        );
      } else if (_exposedHeightFill == 3) {
        var spacing = 4;

        drawArrow(
          dc,
          0,
          x0,
          y0 - spacing / 2,
          _halfHeight,
          _width,
          X_ALIGN_LEFT,
          Y_ALIGN_BOTTOM,
          UP
        );
        drawScrollingText(
          dc,
          0,
          x0 + _arrowWidth + spacing,
          y0 - spacing / 2,
          _halfHeight,
          _width - _arrowWidth - spacing,
          X_ALIGN_LEFT,
          Y_ALIGN_BOTTOM,
          _exposedHeight1 + "m"
        );
        drawArrow(
          dc,
          1,
          x0,
          bottomY0 + spacing / 2,
          _halfHeight,
          _width,
          X_ALIGN_LEFT,
          Y_ALIGN_TOP,
          DOWN
        );
        drawScrollingText(
          dc,
          1,
          x0 + _arrowWidth + spacing,
          bottomY0 + spacing / 2,
          _halfHeight,
          _width - _arrowWidth - spacing,
          X_ALIGN_LEFT,
          Y_ALIGN_TOP,
          _exposedHeight2 + "m"
        );
      } else if (_exposedHeightFill == 4) {
        var font = Gfx.FONT_XTINY;
        var fontHeight = Gfx.getFontHeight(font);

        var text = _exposedHeight2 + "-" + _exposedHeight1 + "m";

        drawArrow(
          dc,
          0,
          x0,
          y0 + _height / 2 - fontHeight - fontHeight / 2,
          fontHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_BOTTOM,
          DOWN
        );
        drawScrollingText(
          dc,
          0,
          x0,
          y0 + _height / 2 - fontHeight / 2,
          fontHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_CENTER,
          text
        );
        drawArrow(
          dc,
          1,
          x0,
          y0 + _height / 2 + fontHeight / 2,
          fontHeight,
          _width,
          X_ALIGN_CENTER,
          Y_ALIGN_TOP,
          UP
        );
      }
    }

    private function drawScrollingText(
      dc as Gfx.Dc,
      textIndex as Number,
      x0 as Numeric,
      y0 as Numeric,
      height as Numeric,
      width as Numeric,
      xAlignment as TextElementsXAlignment,
      yAlignment as TextElementsYAlignment,
      text as String
    ) {
      if (_scrollingTexts[textIndex] == null) {
        _scrollingTexts[textIndex] = new AvalancheUi.ScrollingText({
          :text => text,
          :containerWidth => width,
          :containerHeight => height,
          :xAlignment => xAlignment,
          :yAlignment => yAlignment,
          :font => _font,
        });
      }

      _scrollingTexts[textIndex].draw(dc, x0, y0);
    }

    private function drawArrow(
      dc as Gfx.Dc,
      arrowIndex as Number,
      x0 as Numeric,
      y0 as Numeric,
      height as Numeric,
      width as Numeric,
      xAlignment as TextElementsXAlignment,
      yAlignment as TextElementsYAlignment,
      direction as AvalancheUi.ArrowDirection
    ) {
      if (_arrows[arrowIndex] == null) {
        _arrows[arrowIndex] = new AvalancheUi.Arrow({
          :width => _arrowWidth,
          :height => _arrowHeight,
          :color => _dangerFillColor,
          :direction => direction,
        });
      }

      var arrowXOffset = 0;
      if (xAlignment == X_ALIGN_CENTER) {
        arrowXOffset = width / 2 - _arrowWidth / 2;
      }

      var arrowYOffset = yAlignment == Y_ALIGN_TOP ? 0 : height - _arrowHeight;
      _arrows[arrowIndex].draw(dc, x0 + arrowXOffset, y0 + arrowYOffset);
    }
  }
}
