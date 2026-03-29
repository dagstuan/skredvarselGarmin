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
    :regionId as String,
    :regionName as String,
    :forecast as SimpleAvalancheForecast,
    :isLocationForecast as Boolean,
  };

  (:glance)
  function drawForecastTimeline(
    dc as Gfx.Dc,
    settings as ForecastTimelineSettings
  ) as Void {
    var locX = settings[:locX];
    var locY = settings[:locY];
    var width = settings[:width];
    var height = settings[:height];
    var forecast = settings[:forecast] as SimpleAvalancheForecast;
    var regionName = settings[:regionName] as String?;
    var isLocationForecast = settings[:isLocationForecast] == true;

    var daysToShow = 4;
    var gapX = 3;
    var gapY = 4;
    var lineHeight = 8;
    var dangerLevelGapY = -1;
    var numGaps = daysToShow - 1;

    var lengthPerFullElem = (width - numGaps * gapX) / daysToShow;

    var fontHeight = Gfx.getFontHeight(Gfx.FONT_GLANCE);
    var totalHeight =
      fontHeight + gapY + lineHeight + dangerLevelGapY + fontHeight;
    if (settings[:alignLineCenter]) {
      totalHeight += gapY;
    }

    if ($.DrawOutlines) {
      $.drawOutline(dc, locX, locY, width, height);
    }

    var currYOffset = locY + (height / 2 - totalHeight / 2);

    // Draw title
    if ($.DrawOutlines) {
      $.drawOutline(dc, locX, currYOffset, width, fontHeight);
    }

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      locX,
      currYOffset,
      Gfx.FONT_GLANCE,
      regionName,
      Gfx.TEXT_JUSTIFY_LEFT
    );

    if (isLocationForecast) {
      var textDimensions = dc.getTextDimensions(regionName, Gfx.FONT_GLANCE);

      var iconSize = $.getDeviceScreenWidth() > 280 ? 20 : 13;
      var iconGap = iconSize == 20 ? 6 : 4;
      var iconX = locX + textDimensions[0] + iconGap;
      var iconY = currYOffset + textDimensions[1] / 2 - iconSize / 2;
      var scale = iconSize / 100.0;
      dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      dc.fillPolygon([
        [iconX + 87.13 * scale, iconY + 0.0],
        [iconX + 86.49 * scale, iconY + 0.09 * scale],
        [iconX + 85.61 * scale, iconY + 0.55 * scale],
        [iconX + 11.34 * scale, iconY + 62.37 * scale],
        [iconX + 12.96 * scale, iconY + 66.59 * scale],
        [iconX + 50.92 * scale, iconY + 65.11 * scale],
        [iconX + 68.62 * scale, iconY + 98.73 * scale],
        [iconX + 73.08 * scale, iconY + 98.02 * scale],
        [iconX + 89.48 * scale, iconY + 2.79 * scale],
        [iconX + 87.14 * scale, iconY + 0.0],
      ]);
    }

    currYOffset += fontHeight + gapY;

    // cutoff = 2 days ago, in seconds
    var earlyCutoffTime = new Time.Moment(Time.now().value() - 2 * Gregorian.SECONDS_PER_DAY);
    var oneDaySeconds = Gregorian.SECONDS_PER_DAY.toFloat();
    var currXOffset = locX;

    for (var i = 0; i < forecast.size(); i++) {
      var warning = forecast[i] as SimpleAvalancheWarning;
      var validity = warning["validity"] as Array?;

      if (validity == null || validity.size() < 2) {
        continue;
      }

      var validTo = $.parseDate(validity[1]);
      if (validTo.lessThan(earlyCutoffTime)) {
        continue;
      }

      var lengthThisElem = lengthPerFullElem;
      var spaceLeft = width - currXOffset;
      if (lengthThisElem > spaceLeft) {
        lengthThisElem = spaceLeft;
        if (lengthThisElem <= 0) {
          break;
        }
      }

      var validFrom = $.parseDate(validity[0]);
      if (validFrom.lessThan(earlyCutoffTime)) {
        var durationToShow = validTo.compare(earlyCutoffTime);
        lengthThisElem = lengthThisElem * (durationToShow / oneDaySeconds);
      }

      var dangerLevel = warning["dangerLevel"];
      var hasEmergency = warning["hasEmergency"];

      var color = colorize(dangerLevel);
      dc.setColor(color, Gfx.COLOR_TRANSPARENT);
      dc.fillRectangle(currXOffset, currYOffset, lengthThisElem, lineHeight);

      var dangerLevelString = dangerLevel.toString();
      if (hasEmergency) {
        dangerLevelString += "!";
      }

      var textWidth = dc.getTextWidthInPixels(dangerLevelString, Gfx.FONT_GLANCE);
      if (currXOffset > locX && textWidth < lengthThisElem) {
        var textY0 = currYOffset + dangerLevelGapY + lineHeight;

        if ($.DrawOutlines) {
          $.drawOutline(dc, currXOffset, textY0, textWidth, fontHeight);
        }

        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
          currXOffset,
          textY0,
          Gfx.FONT_GLANCE,
          dangerLevelString,
          Gfx.TEXT_JUSTIFY_LEFT
        );
      }

      currXOffset += lengthThisElem + gapX;
    }

    var markerWidth = 3;
    var markerHeight = 16;
    var strokeOffset = 4;
    var markerX = (locX + width) / 2 - markerWidth / 2;
    var markerY = currYOffset - markerHeight / 4;
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.fillRectangle(
      markerX - strokeOffset / 2,
      markerY,
      markerWidth + strokeOffset,
      markerHeight
    );
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
    dc.fillRectangle(markerX, markerY, markerWidth, markerHeight);
  }
}
