import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  class ForecastElementsIndicator {
    private var _numElements as Number;

    private var _indicatorWidth = 4;
    private var _paddingFromEdge = _indicatorWidth;

    private var _degreesPerElement = 3;
    private var _degreesPaddingBetweenElements = 2;

    public function initialize(numElements as Number) {
      _numElements = numElements;
    }

    public function draw(dc as Gfx.Dc, selectedIndex as Number) as Void {
      if (_numElements < 2) {
        return;
      }

      dc.setAntiAlias(true);
      dc.setPenWidth(_indicatorWidth);
      var width = dc.getWidth();
      var height = dc.getHeight();

      var cX = width / 2;
      var cY = height / 2;
      var rad = width / 2 - _paddingFromEdge; // Assume circular screen

      var centerAngle = 30;

      var degreesPadding = _degreesPaddingBetweenElements * (_numElements - 1);

      var totalLengthDegrees =
        _numElements * _degreesPerElement + degreesPadding;
      var angle = centerAngle + totalLengthDegrees / 2;

      for (var i = 0; i < _numElements; i++) {
        if (i == selectedIndex) {
          dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        } else {
          dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        }

        dc.drawArc(
          cX,
          cY,
          rad,
          Gfx.ARC_CLOCKWISE,
          angle,
          angle - _degreesPerElement
        );

        angle = angle - _degreesPerElement - _degreesPaddingBetweenElements;
      }
    }
  }
}
