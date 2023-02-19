import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;

module AvalancheUi {
  typedef ForecastTimelineSettings as {
    :locX as Numeric,
    :locY as Numeric,
    :width as Numeric,
    :height as Numeric,
  };

  (:glance)
  class ForecastTimeline {
    private var _regionId as String?;
    private var _forecast as SimpleAvalancheForecast?;

    private var _numWarnings;

    private var _daysToShow = 4;
    private var _gap = 3;
    private var _numGaps = _daysToShow - 1;
    private var _lineHeight = 8;

    private var _markerWidth = 3;
    private var _markerHeight = 18;
    private var _strokeOffset = 4;

    private var _oneDayValue = (new Time.Duration(Gregorian.SECONDS_PER_DAY))
      .value()
      .toFloat();

    private var _earlyCutoffTime as Time.Moment?;

    private var _locX as Numeric?;
    private var _locY as Numeric?;
    private var _width as Numeric?;
    private var _height as Numeric?;

    public function setSettings(settings as ForecastTimelineSettings) {
      _locX = settings[:locX];
      _locY = settings[:locY];
      _width = settings[:width];
      _height = settings[:height];
    }

    private function setEarlyCutoffTime() {
      var now = Time.getCurrentTime({
        :currentTimeType => Time.CURRENT_TIME_DEFAULT,
      });
      _earlyCutoffTime = now.subtract(
        new Time.Duration(Gregorian.SECONDS_PER_DAY * 2)
      );
    }

    public function setData(
      regionId as String,
      forecast as SimpleAvalancheForecast
    ) {
      _regionId = regionId;
      _forecast = forecast;

      _numWarnings = _forecast.warnings.size();

      setEarlyCutoffTime();
    }

    public function draw(dc as Gfx.Dc) {
      if (_forecast == null) {
        return;
      }

      drawTitle(dc, _locX, _locY);

      var lengthPerFullElem = (_width - _numGaps * _gap) / _daysToShow;

      var currXOffset = _locX;

      for (var i = 0; i < _numWarnings; i++) {
        var warning = _forecast.warnings[i];

        var validFrom = warning.validFrom;
        var validTo = warning.validTo;

        if (validTo.lessThan(_earlyCutoffTime)) {
          // Forecast is earlier than we will render.
          continue;
        }

        var lengthThisElem = lengthPerFullElem;
        var spaceLeft = _width - currXOffset;

        if (lengthThisElem > spaceLeft) {
          lengthThisElem = spaceLeft;

          if (lengthThisElem <= 0) {
            // no room for this element
            continue;
          }
        }

        if (validFrom.lessThan(_earlyCutoffTime)) {
          // First element will be shorter

          var durationToShow = validTo.compare(_earlyCutoffTime);
          var percentToShow = durationToShow / _oneDayValue;
          lengthThisElem = lengthThisElem * percentToShow;
        }

        var dangerLevel = warning.dangerLevel;
        var color = colorize(dangerLevel);

        var lineStart = currXOffset;
        var lineEnd = currXOffset + lengthThisElem;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        dc.fillRectangle(
          lineStart,
          _locY + (_height / 2 - _lineHeight / 2),
          lineEnd - lineStart,
          _lineHeight
        );

        var dangerLevelString = dangerLevel.toString();
        var font = Graphics.FONT_GLANCE;
        var textWidth = dc.getTextWidthInPixels(dangerLevelString, font);
        if (currXOffset > _locX && textWidth < lengthThisElem) {
          dc.setColor(color, Graphics.COLOR_TRANSPARENT);
          dc.drawText(
            currXOffset,
            _locY + (_height - dc.getFontHeight(font)),
            font,
            dangerLevel.toString(),
            Graphics.TEXT_JUSTIFY_LEFT
          );
        }

        currXOffset += lengthThisElem + _gap;
      }

      drawMarker(dc, _locX, _locY, _width, _height);
    }

    private function drawTitle(dc as Gfx.Dc, x0 as Number, y0 as Number) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

      dc.drawText(
        x0,
        y0,
        Graphics.FONT_GLANCE,
        $.Regions[_regionId],
        Graphics.TEXT_JUSTIFY_LEFT
      );
    }

    private function drawMarker(
      dc as Gfx.Dc,
      x0 as Number,
      y0 as Number,
      width as Number,
      height as Number
    ) {
      var markerX = (x0 + width) / 2 - _markerWidth / 2;
      var minY = height / 2 - _markerHeight / 2;

      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.fillRectangle(
        markerX - _strokeOffset / 2,
        y0 + minY,
        _markerWidth + _strokeOffset,
        _markerHeight
      );
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      dc.fillRectangle(markerX, y0 + minY, _markerWidth, _markerHeight);
    }
  }
}
