import Toybox.Lang;

using Toybox.Graphics as Gfx;

module AvalancheUi {
  class ForecastElementsIndicator {
    private var _numElements as Number;

    private var _indicatorWidth = 4;
    private var _paddingFromEdge = _indicatorWidth;

    private var _degreesPerElement = 3;
    private var _degreesPaddingBetweenElements = 2;

    private var _centerAngle = 30;
    private var _totalLengthDegrees as Number;

    public function initialize(numElements as Number) {
      _numElements = numElements;

      var degreesPadding = _degreesPaddingBetweenElements * (_numElements - 1);

      _totalLengthDegrees = _numElements * _degreesPerElement + degreesPadding;
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

      var angle = _centerAngle + _totalLengthDegrees / 2;

      for (var i = 0; i < _numElements; i++) {
        dc.setColor(
          i == selectedIndex ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY,
          Gfx.COLOR_TRANSPARENT
        );

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
