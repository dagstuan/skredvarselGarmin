import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance)
class AvalancheForecastRenderer {
  private var _regionId as String;
  private var _forecast as AvalancheForecast;
  private var _marginRight;

  private var _numWarnings;

  private var _daysToShow = 4;
  private var _gap = 4;
  private var _numGaps = _daysToShow - 1;
  private var _lineHeight = 8;

  private var _markerWidth = 3;
  private var _markerHeight = 18;
  private var _strokeOffset = 4;

  private var _oneDayValue = (new Time.Duration(Gregorian.SECONDS_PER_DAY))
    .value()
    .toFloat();
  private var _twoDays = new Time.Duration(Gregorian.SECONDS_PER_DAY * 2);

  public function initialize(
    regionId as String,
    forecast as AvalancheForecast,
    marginRight as Number
  ) {
    _regionId = regionId;
    _forecast = forecast;
    _marginRight = marginRight;

    _numWarnings = _forecast.warnings.size();
  }

  public function draw(dc as Gfx.Dc) {
    var width = dc.getWidth() - _marginRight;
    var height = dc.getHeight();

    drawTitle(dc);

    var lengthPerFullElem = (width - _numGaps * _gap) / _daysToShow;

    var now = Time.getCurrentTime({
      :currentTimeType => Time.CURRENT_TIME_DEFAULT,
    });
    var earlyCutoffTime = now.subtract(_twoDays);

    var currXOffset = 0;

    for (var i = 0; i < _numWarnings; i++) {
      var warning = _forecast.warnings[i];

      var validFrom = warning.validFrom;
      var validTo = warning.validTo;

      if (validTo.lessThan(earlyCutoffTime)) {
        // Forecast is earlier than we will render.
        continue;
      }

      var lengthThisElem = lengthPerFullElem;

      if (currXOffset + lengthThisElem > width) {
        lengthThisElem -= width - currXOffset;

        if (lengthThisElem <= 0) {
          // no room for this element
          continue;
        }
      }

      if (validFrom.lessThan(earlyCutoffTime)) {
        // First element will be shorter

        var durationToShow = validTo.compare(earlyCutoffTime);
        var percentToShow = durationToShow / _oneDayValue;
        lengthThisElem = lengthThisElem * percentToShow;
      }

      var dangerLevel = warning.dangerLevel;
      var color = colorize(dangerLevel.toNumber());

      var lineStart = currXOffset;
      var lineEnd = currXOffset + lengthThisElem;

      dc.setColor(color, Graphics.COLOR_TRANSPARENT);

      dc.fillRectangle(
        lineStart,
        height / 2 - _lineHeight / 2,
        lineEnd - lineStart,
        _lineHeight
      );

      if (lengthThisElem == lengthPerFullElem) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          currXOffset,
          height - dc.getFontHeight(Graphics.FONT_GLANCE),
          Graphics.FONT_GLANCE,
          dangerLevel,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }

      currXOffset += lengthThisElem + _gap;
    }

    drawMarker(dc);
  }

  private function drawTitle(dc as Gfx.Dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    dc.drawText(
      0,
      0,
      Graphics.FONT_GLANCE,
      $.Regions[_regionId],
      Graphics.TEXT_JUSTIFY_LEFT
    );
  }

  private function drawMarker(dc as Gfx.Dc) {
    var width = dc.getWidth() - _marginRight;
    var height = dc.getHeight();

    var markerX = width / 2 - _markerWidth / 2;

    var minY = height / 2 - _markerHeight / 2;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.fillRectangle(
      markerX - _strokeOffset / 2,
      minY,
      _markerWidth + _strokeOffset,
      _markerHeight
    );
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    dc.fillRectangle(markerX, minY, _markerWidth, _markerHeight);
  }
}
