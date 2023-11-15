import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time;

module AvalancheUi {
  typedef ForecastTimelineSettings as {
    :locX as Numeric,
    :locY as Numeric,
    :width as Numeric,
    :height as Numeric,
    :regionId as String,
    :regionName as String,
    :forecast as SimpleAvalancheForecast,
  };

  (:glance)
  class ForecastTimeline {
    private var _forecast as SimpleAvalancheForecast;

    private var _numWarnings;

    private var _daysToShow = 4;
    private var _gap = 3;
    private var _numGaps = _daysToShow - 1;
    private var _lineHeight = 8;

    private var _markerWidth = 3;
    private var _markerHeight = 18;
    private var _strokeOffset = 4;

    private var _oneDayValue = $.dayDuration(1).value().toFloat();

    private var _earlyCutoffTime as Time.Moment;

    private var _locX as Numeric;
    private var _locY as Numeric;
    private var _width as Numeric;
    private var _height as Numeric;

    private var _lengthPerFullElem as Numeric;

    private var _dangerLevelFont = Gfx.FONT_GLANCE;

    private var _regionName as String?;

    public function initialize(settings as ForecastTimelineSettings) {
      _locX = settings[:locX];
      _locY = settings[:locY];
      _width = settings[:width];
      _height = settings[:height];
      _lengthPerFullElem = (_width - _numGaps * _gap) / _daysToShow;

      _regionName = settings[:regionName];
      _forecast = settings[:forecast];

      _numWarnings = _forecast.size();

      var now = Time.getCurrentTime({
        :currentTimeType => Time.CURRENT_TIME_DEFAULT,
      });
      _earlyCutoffTime = $.subtractDays(now, 2);
    }

    public function draw(dc as Gfx.Dc) {
      drawTitle(dc, _locX, _locY);

      var currXOffset = _locX;

      for (var i = 0; i < _numWarnings; i++) {
        var lengthDrawn = drawWarning(dc, currXOffset, _forecast[i]);

        if (lengthDrawn > 0) {
          currXOffset += lengthDrawn + _gap;
        }
      }

      drawMarker(dc, _locX, _locY, _width, _height);
    }

    private function drawWarning(
      dc as Gfx.Dc,
      x0 as Numeric,
      warning as SimpleAvalancheWarning
    ) as Numeric {
      var validity = warning["validity"] as Array;
      var validFrom = $.parseDate(validity[0]);
      var validTo = $.parseDate(validity[1]);
      var dangerLevel = warning["dangerLevel"];

      if (validTo.lessThan(_earlyCutoffTime)) {
        // Forecast is earlier than we will render.
        return 0;
      }

      var lengthThisElem = _lengthPerFullElem;
      var spaceLeft = _width - x0;

      if (lengthThisElem > spaceLeft) {
        lengthThisElem = spaceLeft;

        if (lengthThisElem <= 0) {
          // no room for this element
          return 0;
        }
      }

      if (validFrom.lessThan(_earlyCutoffTime)) {
        // First element will be shorter

        var durationToShow = validTo.compare(_earlyCutoffTime);
        var percentToShow = durationToShow / _oneDayValue;
        lengthThisElem = lengthThisElem * percentToShow;
      }

      var color = colorize(dangerLevel);
      dc.setColor(color, Graphics.COLOR_TRANSPARENT);

      dc.fillRectangle(
        x0,
        _locY + (_height / 2 - _lineHeight / 2),
        lengthThisElem,
        _lineHeight
      );

      var dangerLevelString = dangerLevel.toString();
      var textWidth = dc.getTextWidthInPixels(
        dangerLevelString,
        _dangerLevelFont
      );
      if (x0 > _locX && textWidth < lengthThisElem) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          x0,
          _locY + _height / 2 + _height * 0.05,
          _dangerLevelFont,
          dangerLevelString,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }

      return lengthThisElem;
    }

    private function drawTitle(dc as Gfx.Dc, x0 as Number, y0 as Number) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

      dc.drawText(
        x0,
        y0,
        Graphics.FONT_GLANCE,
        _regionName,
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
