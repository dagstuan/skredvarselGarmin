import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  typedef ExposedHeightSettings as {
    :exposedHeight1 as Number,
    :exposedHeight2 as Number,
    :exposedHeightFill as Number,
    :dangerFillColor as Gfx.ColorType,
    :nonDangerFillColor as Gfx.ColorType,
    :size as Numeric,
  };

  public class ExposedHeight {
    private const _topHalfPoints = [
      [34.1299, 22.8691],
      [20.1809, 1.0741],
      [19.7079, 0.3711],
      [19.1749, 0.0461],
      [18.5749, 0.0961],
      [17.9749, 0.1461],
      [17.4999, 0.5581],
      [17.1459, 1.3301],
      [8.5139, 18.9511],
      [10.8769, 18.8161],
      [12.7759, 20.6831],
      [12.7759, 20.6831],
      [13.8629, 21.6761],
      [14.2179, 22.0151],
      [16.1509, 22.0291],
      [19.1399, 22.0511],
      [20.0179, 20.7691],
      [22.0269, 21.4881],
      [24.3919, 22.3371],
      [25.3159, 23.3921],
      [27.1709, 24.5401],
      [29.9429, 26.2481],
      [31.3449, 26.2291],
      [33.0259, 25.1611],
      [33.0259, 25.1611],
      [34.6099, 24.2071],
      [34.1299, 22.8691],
    ];

    private const _bottomHalfPoints = [
      [6.4121, 23.752],
      [1.0791, 34.822],
      [0.6321, 35.565],
      [0.5661, 36.549],
      [0.8771, 37.084],
      [1.1851, 37.623],
      [1.7671, 38.58],
      [2.6191, 38.58],
      [39.6821, 38.58],
      [40.5341, 38.58],
      [41.1151, 37.623],
      [41.4251, 37.084],
      [41.7341, 36.549],
      [41.6681, 35.219],
      [41.2231, 34.479],
      [36.2291, 26.217],
      [36.4201, 27.445],
      [34.3141, 28.854],
      [34.3141, 28.854],
      [32.6091, 29.992],
      [30.3481, 29.959],
      [27.8371, 28.975],
      [25.7441, 28.152],
      [24.4491, 26.895],
      [22.4571, 25.955],
      [20.4671, 25.012],
      [19.3401, 26.041],
      [16.5901, 26.281],
      [14.9531, 26.424],
      [13.9711, 26.166],
      [12.6221, 25.324],
      [12.6221, 25.324],
      [9.9561, 23.752],
      [6.4601, 23.752],
      [6.4121, 23.752],
    ];

    private const _topTripletPoints = [
      [23.917, 10.0605],
      [19.813, 2.6985],
      [19.387, 2.0665],
      [18.906, 1.7735],
      [18.367, 1.8185],
      [17.826, 1.8645],
      [17.4, 2.2345],
      [17.08, 2.9285],
      [14.471, 8.8895],
      [14.384, 9.0545],
      [14.384, 9.0545],
      [16.84, 8.2885],
      [18.863, 9.4345],
      [20.521, 10.3725],
      [21.144, 11.3805],
      [23.917, 10.0605],
    ];

    private const _midTripletPoints = [
      [34.2402, 27.625],
      [34.2402, 28.483],
      [33.0472, 29.218],
      [33.0472, 29.218],
      [31.3652, 30.286],
      [29.3092, 30.762],
      [26.6252, 28.92],
      [24.6822, 27.587],
      [23.7362, 26.562],
      [21.4802, 25.868],
      [19.4402, 25.241],
      [18.5942, 26.431],
      [15.6052, 26.409],
      [13.6722, 26.396],
      [13.2832, 25.827],
      [12.2282, 25.063],
      [12.2282, 25.063],
      [10.6742, 23.747],
      [8.6982, 23.268],
      [8.0602, 23.169],
      [12.9712, 12.208],
      [12.9712, 12.208],
      [16.3302, 11.472],
      [18.5802, 12.745],
      [20.4222, 13.788],
      [23.3102, 15.342],
      [25.7672, 13.209],
      [34.2402, 27.625],
    ];

    private const _bottomTripletPoints = [
      [5.9922, 27.7842],
      [0.8322, 39.2022],
      [0.3852, 39.9442],
      [0.3202, 40.9292],
      [0.6312, 41.4642],
      [0.9392, 42.0032],
      [1.5212, 42.9602],
      [2.3732, 42.9602],
      [39.4352, 42.9602],
      [40.2872, 42.9602],
      [40.8692, 42.0032],
      [41.1782, 41.4642],
      [41.4882, 40.9292],
      [41.4222, 39.5982],
      [40.9762, 38.8582],
      [36.0102, 30.6382],
      [35.9552, 31.7022],
      [34.0682, 33.2332],
      [34.0682, 33.2332],
      [32.3632, 34.3722],
      [30.1012, 34.3392],
      [27.5902, 33.3542],
      [25.4982, 32.5322],
      [24.2032, 31.2742],
      [22.2112, 30.3352],
      [20.2212, 29.3912],
      [19.0942, 30.4212],
      [16.3442, 30.6612],
      [14.7072, 30.8042],
      [13.7242, 30.5462],
      [12.3752, 29.7042],
      [12.3752, 29.7042],
      [9.9982, 27.7842],
      [6.5022, 27.7842],
      [5.9922, 27.7842],
    ];

    private var _exposedHeightFill as Number;
    private var _size as Numeric;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    private var _bufferedBitmap as Gfx.BufferedBitmap?;

    public function initialize(settings as ExposedHeightSettings) {
      _exposedHeightFill = settings[:exposedHeightFill];
      _size = settings[:size];
      _dangerFillColor = settings[:dangerFillColor];
      _nonDangerFillColor = settings[:nonDangerFillColor];
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) {
      if (_bufferedBitmap == null) {
        createBufferedBitmap();
      }

      dc.drawBitmap(x0, y0, _bufferedBitmap);
    }

    private function createBufferedBitmap() {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _size,
        :height => _size,
      });

      var bufferedDc = _bufferedBitmap.getDc();

      if ($.DrawOutlines) {
        $.drawOutline(bufferedDc, 0, 0, _size, _size);
      }

      bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
      bufferedDc.setPenWidth(1);
      bufferedDc.setAntiAlias(true);

      if (_exposedHeightFill == 1) {
        drawPoly(bufferedDc, _topHalfPoints, _dangerFillColor);
        drawPoly(bufferedDc, _bottomHalfPoints, _nonDangerFillColor);
      } else if (_exposedHeightFill == 2) {
        drawPoly(bufferedDc, _topHalfPoints, _nonDangerFillColor);
        drawPoly(bufferedDc, _bottomHalfPoints, _dangerFillColor);
      } else if (_exposedHeightFill == 3) {
        drawPoly(bufferedDc, _topTripletPoints, _dangerFillColor);
        drawPoly(bufferedDc, _midTripletPoints, _nonDangerFillColor);
        drawPoly(bufferedDc, _bottomTripletPoints, _dangerFillColor);
      } else if (_exposedHeightFill == 4) {
        drawPoly(bufferedDc, _topTripletPoints, _nonDangerFillColor);
        drawPoly(bufferedDc, _midTripletPoints, _dangerFillColor);
        drawPoly(bufferedDc, _bottomTripletPoints, _nonDangerFillColor);
      }
    }

    private function drawPoly(
      dc as Gfx.Dc,
      points as Array<Array<Numeric> >,
      color as Gfx.ColorType
    ) {
      var calculatedPoints = calcPoints(points);

      dc.setColor(color, color);

      dc.fillPolygon(calculatedPoints);
    }

    private function calcPoints(
      points as Array<Array<Numeric> >
    ) as Array<Array<Numeric> > {
      var numPoints = points.size();
      var ret = new [numPoints];
      for (var i = 0; i < points.size(); i++) {
        var point = points[i];
        ret[i] = calcPoint(point[0], point[1]);
      }
      return ret;
    }

    private function calcPoint(x as Numeric, y as Numeric) as Array<Numeric> {
      var scalingFactor = _size / 42.0;

      return [x * scalingFactor, y * scalingFactor];
    }
  }
}
