import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  typedef AvalancheProblemSettings as {
    :problem as AvalancheProblem,
    :locX as Numeric,
    :locY as Numeric,
    :width as Numeric,
    :height as Numeric,
    :dangerFillColor as Gfx.ColorType,
    :nonDangerFillColor as Gfx.ColorType,
  };

  public class AvalancheProblemUi {
    private var _typeName as String;
    private var _exposedHeights as Array<Number>;
    private var _validExpositions as String;
    private var _dangerLevel as Number;

    private var _width as Numeric;
    private var _height as Numeric;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    private var _elemWidth as Number;
    private var _elemHeight as Number;
    private var _paddingLeftRight as Number = 0;
    private var _paddingBetween as Number;

    private var _dangerLevelWidth = 4;

    private var _problemText as AvalancheUi.ScrollingText?;
    private var _validExpositionsUi as AvalancheUi.ValidExpositions?;
    private var _exposedHeightUi as AvalancheUi.ExposedHeight?;
    private var _exposedHeightTextUi as AvalancheUi.ExposedHeightText?;

    public function initialize(settings as AvalancheProblemSettings) {
      var problem = settings[:problem];

      _typeName = problem["typeName"];
      _exposedHeights = problem["exposedHeights"];
      _validExpositions = problem["validExpositions"];
      _dangerLevel = problem["dangerLevel"];

      _width = settings[:width];
      _height = settings[:height];

      var deviceScreenWidth = $.getDeviceScreenWidth();
      if (deviceScreenWidth > 240) {
        _paddingLeftRight = (_width * 0.08).toNumber();
      }

      _paddingBetween = (_width * 0.04).toNumber();
      _elemHeight = (_height * 0.75).toNumber();
      _elemWidth = (
        (_width -
          _dangerLevelWidth -
          _paddingLeftRight * 2 -
          _paddingBetween * 3) /
        3
      ).toNumber();

      _dangerFillColor = Gfx.COLOR_RED;
      _nonDangerFillColor = Gfx.COLOR_LT_GRAY;
    }

    public function onShow() as Void {
      if (_problemText != null) {
        _problemText.onShow();
      }
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.onShow();
      }
    }

    public function onHide() as Void {
      if (_problemText != null) {
        _problemText.onHide();
      }
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.onHide();
      }
    }

    public function onTick() as Void {
      if (_problemText != null) {
        _problemText.onTick();
      }
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.onTick();
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      drawProblemText(dc, x0, y0);

      var elemX0 = x0 + _paddingLeftRight;
      var elemY0 = y0 + _height - _elemHeight;
      // x0 and y0 for expositions are the center of the circle.
      drawExpositions(dc, elemX0, elemY0);

      elemX0 += _elemWidth + _paddingBetween;
      drawExposedHeight(dc, elemX0, elemY0);

      elemX0 += _elemWidth + _paddingBetween;
      drawExposedHeightText(dc, elemX0, elemY0);

      elemX0 += _elemWidth + _paddingBetween;
      drawDangerLevel(dc, elemX0, elemY0);
    }

    private function drawProblemText(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      if (_problemText == null) {
        _problemText = new ScrollingText({
          :text => _typeName,
          :containerWidth => _width,
          :containerHeight => _height * 0.25,
          :font => Gfx.FONT_XTINY,
        });
      }

      _problemText.draw(dc, x0, y0);
    }

    private function drawDangerLevel(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      var color = $.colorize(_dangerLevel);
      dc.setColor(color, Gfx.COLOR_TRANSPARENT);

      var minSize = $.min(_elemWidth, _elemHeight);

      dc.fillRectangle(x0, y0 + _elemHeight / 2 - minSize / 2, 4, minSize);
    }

    private function drawExpositions(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      if (_validExpositionsUi == null) {
        var minSize = $.min(_elemWidth, _elemHeight);

        _validExpositionsUi = new AvalancheUi.ValidExpositions({
          :validExpositions => _validExpositions,
          :dangerFillColor => _dangerFillColor,
          :nonDangerFillColor => _nonDangerFillColor,
          :radius => minSize / 2,
        });
      }

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _elemWidth, _elemHeight);
      }

      var shiftX = _elemWidth / 2.0;
      var shiftY = _elemHeight / 2.0;
      _validExpositionsUi.draw(dc, x0 + shiftX, y0 + shiftY);
    }

    private function drawExposedHeight(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      var minSize = $.min(_elemWidth, _elemHeight);

      var sizeModifier = 0.9;
      var exposedWidth = minSize * sizeModifier;

      if (_exposedHeightUi == null) {
        _exposedHeightUi = new AvalancheUi.ExposedHeight({
          :exposedHeight1 => _exposedHeights[0],
          :exposedHeight2 => _exposedHeights[1],
          :exposedHeightFill => _exposedHeights[2],
          :dangerFillColor => _dangerFillColor,
          :nonDangerFillColor => _nonDangerFillColor,
          :size => exposedWidth,
        });
      }

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _elemWidth, _elemHeight);
      }

      var shiftX = _elemWidth / 2.0 - exposedWidth / 2.0;
      var shiftY = _elemHeight / 2.0 - exposedWidth / 2.0;

      _exposedHeightUi.draw(dc, x0 + shiftX, y0 + shiftY);
    }

    private function drawExposedHeightText(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      if (_exposedHeightTextUi == null) {
        _exposedHeightTextUi = new AvalancheUi.ExposedHeightText({
          :exposedHeight1 => _exposedHeights[0],
          :exposedHeight2 => _exposedHeights[1],
          :exposedHeightFill => _exposedHeights[2],
          :dangerFillColor => _dangerFillColor,
          :width => _elemWidth,
          :height => _elemHeight,
        });
      }

      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _elemWidth, _elemHeight);
      }

      _exposedHeightTextUi.draw(dc, x0, y0);
    }
  }
}
