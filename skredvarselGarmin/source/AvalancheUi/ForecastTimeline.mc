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
    :isLocationForecast as Boolean,
    :alignLineCenter as Boolean?,
  };

  (:glance)
  class ForecastTimeline {
    private var _forecast as SimpleAvalancheForecast;
    private var _isLocationForecast as Boolean;

    private var _numWarnings;

    private var _daysToShow = 4;
    private var _gapY = 4;
    private var _gapX = 3;
    private var _numGaps = _daysToShow - 1;
    private var _lineHeight = 8;
    private var _fontHeight = Gfx.getFontHeight(Gfx.FONT_GLANCE);
    private var _dangerLevelGapY = -1;
    private var _totalHeight =
      _fontHeight + _gapY + _lineHeight + _dangerLevelGapY + _fontHeight;

    private var _markerWidth = 3;
    private var _markerHeight = 16;
    private var _strokeOffset = 4;

    private var _navigationIconGap = 4;

    private var _oneDayValue = $.dayDuration(1).value().toFloat();

    private var _earlyCutoffTime as Time.Moment;

    private var _locX as Numeric;
    private var _locY as Numeric;
    private var _width as Numeric;
    private var _height as Numeric;

    private var _lengthPerFullElem as Numeric;

    private var _regionName as String?;

    private var _navigationIcon as AvalancheUi.NavigationIcon?;

    public function initialize(settings as ForecastTimelineSettings) {
      _locX = settings[:locX];
      _locY = settings[:locY];
      _width = settings[:width];
      _height = settings[:height];
      _lengthPerFullElem = (_width - _numGaps * _gapX) / _daysToShow;

      _regionName = settings[:regionName];
      _forecast = settings[:forecast];

      if (settings[:alignLineCenter]) {
        _totalHeight += _gapY;
      }

      _numWarnings = _forecast.size();

      var now = Time.getCurrentTime({
        :currentTimeType => Time.CURRENT_TIME_DEFAULT,
      });
      _earlyCutoffTime = $.subtractDays(now, 2);
      _isLocationForecast =
        settings[:isLocationForecast] != null
          ? settings[:isLocationForecast]
          : false;

      if (_isLocationForecast) {
        var navigationIconSize = 13;

        var screenWidth = $.getDeviceScreenWidth();
        if (screenWidth > 280) {
          navigationIconSize = 20;
          _navigationIconGap = 6;
        }

        _navigationIcon = new AvalancheUi.NavigationIcon(navigationIconSize);
      }
    }

    public function draw(dc as Gfx.Dc) {
      if ($.DrawOutlines) {
        $.drawOutline(dc, _locX, _locY, _width, _height);
      }

      var currYOffset = _locY + (_height / 2 - _totalHeight / 2);

      drawTitle(dc, _locX, currYOffset);

      currYOffset += _fontHeight + _gapY;

      var currXOffset = _locX;
      for (var i = 0; i < _numWarnings; i++) {
        var lengthDrawn = drawWarning(
          dc,
          currXOffset,
          currYOffset,
          _forecast[i]
        );

        if (lengthDrawn > 0) {
          currXOffset += lengthDrawn + _gapX;
        }
      }

      drawMarker(dc, _locX, currYOffset);
    }

    private function drawWarning(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric,
      warning as SimpleAvalancheWarning
    ) as Numeric {
      var validity = warning["validity"] as Array;
      var validFrom = $.parseDate(validity[0]);
      var validTo = $.parseDate(validity[1]);
      var dangerLevel = warning["dangerLevel"];
      var hasEmergency = warning["hasEmergency"];

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
      dc.setColor(color, Gfx.COLOR_TRANSPARENT);

      dc.fillRectangle(x0, y0, lengthThisElem, _lineHeight);

      var dangerLevelString = dangerLevel.toString();

      if (hasEmergency) {
        dangerLevelString += "!";
      }

      var textWidth = dc.getTextWidthInPixels(
        dangerLevelString,
        Gfx.FONT_GLANCE
      );
      if (x0 > _locX && textWidth < lengthThisElem) {
        var textY0 = y0 + _dangerLevelGapY + _lineHeight;

        if ($.DrawOutlines) {
          $.drawOutline(dc, x0, textY0, textWidth, _fontHeight);
        }

        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
          x0,
          textY0,
          Gfx.FONT_GLANCE,
          dangerLevelString,
          Gfx.TEXT_JUSTIFY_LEFT
        );
      }

      return lengthThisElem;
    }

    private function drawTitle(dc as Gfx.Dc, x0 as Number, y0 as Number) {
      if ($.DrawOutlines) {
        $.drawOutline(dc, x0, y0, _width, _fontHeight);
      }

      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

      var textDimensions = dc.getTextDimensions(_regionName, Gfx.FONT_GLANCE);

      dc.drawText(x0, y0, Gfx.FONT_GLANCE, _regionName, Gfx.TEXT_JUSTIFY_LEFT);

      if (_navigationIcon != null) {
        var minX = textDimensions[0] + _navigationIconGap;
        var minY = textDimensions[1] / 2 - _navigationIcon.size / 2;

        _navigationIcon.draw(dc, x0 + minX, y0 + minY);
      }
    }

    private function drawMarker(dc as Gfx.Dc, x0 as Number, y0 as Number) {
      var markerX = (x0 + _width) / 2 - _markerWidth / 2;
      var minY = y0 - _markerHeight / 4;

      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
      dc.fillRectangle(
        markerX - _strokeOffset / 2,
        minY,
        _markerWidth + _strokeOffset,
        _markerHeight
      );
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
      dc.fillRectangle(markerX, minY, _markerWidth, _markerHeight);
    }
  }
}
