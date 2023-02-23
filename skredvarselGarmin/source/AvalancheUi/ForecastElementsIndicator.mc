import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  class ForecastElementsIndicator {
    private var _numElements as Number;

    private var _indicatorSize = 4;
    private var _paddingFromEdge = _indicatorSize;

    private var _degreesPaddingBetweenElements = 2;

    public function initialize(numElements as Number) {
      _numElements = numElements;
    }

    public function draw(dc as Gfx.Dc, selectedIndex as Number) as Void {
      if (_numElements == 0) {
        return;
      }

      dc.setAntiAlias(true);
      dc.setPenWidth(_indicatorSize);
      var width = dc.getWidth();
      var height = dc.getHeight();

      var cX = width / 2;
      var cY = height / 2;
      var rad = width / 2 - _paddingFromEdge; // Assume circular screen

      var centerAngle = 30;
      var totalLengthDegrees = 15.0;

      var degreesPadding = _degreesPaddingBetweenElements * (_numElements - 1);
      var degreesPerElement =
        (totalLengthDegrees - degreesPadding) / _numElements;

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
          angle - degreesPerElement
        );

        angle = angle - degreesPerElement - _degreesPaddingBetweenElements;
      }
    }
  }
}
