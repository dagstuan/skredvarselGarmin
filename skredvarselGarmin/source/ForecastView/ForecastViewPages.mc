import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

public class ForecastViewPages extends Ui.Drawable {
  private enum ArrowDirection {
    LEFT = 0,
    RIGHT = 1,
  }

  private var _warning as DetailedAvalancheWarning;

  private var _y0 as Numeric;
  private var _height as Numeric;

  public var currentPage = 0;
  public var animationTime = 0;
  public var numPages as Number;

  public function initialize(
    warning as DetailedAvalancheWarning,
    y0 as Numeric,
    height as Numeric
  ) {
    Drawable.initialize({});

    _y0 = y0;
    _height = height;

    _warning = warning;
    numPages = warning.avalancheProblems.size() + 1;
  }

  public function draw(dc as Gfx.Dc) {
    var fullWidth = dc.getWidth();

    $.drawOutline(dc, 0, _y0, fullWidth, _height);

    var areaWidth = fullWidth * 0.75;
    var areaHeight = _height * 0.9;
    var x0 = fullWidth / 2 - areaWidth / 2;
    var y0 = _y0 + (_height / 2 - areaHeight / 2);

    $.drawOutline(dc, x0, y0, areaWidth, areaHeight);

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);

    // TODO: This needs to be fixed if there is more than two pages.
    var xOffset =
      -(currentPage * fullWidth) - (animationTime / 1000.0) * fullWidth;

    // First page, main text
    drawFirstPage(dc, x0 + xOffset, y0, areaWidth, areaHeight);

    var arrowHeight = areaHeight * 0.1;
    var arrowWidth = areaWidth * 0.02;

    // Draw next arrow for first page
    drawArrow(
      dc,
      x0 + xOffset + areaWidth + arrowWidth,
      y0 + (areaHeight / 2 - arrowHeight / 2),
      arrowWidth,
      arrowHeight,
      RIGHT
    );

    xOffset += fullWidth;

    var problems = _warning.avalancheProblems;
    var numProblems = problems.size();

    for (var i = 0; i < numProblems; i++) {
      // Draw each avalanche problem
      var problem = problems[i];

      var avalancheProblemUi = new AvalancheUi.AvalancheProblemUi({
        :problem => problem,
        :locX => xOffset + x0,
        :locY => y0,
        :width => areaWidth,
        :height => areaHeight,
      });
      avalancheProblemUi.draw(dc);

      // Arrows
      // Left
      drawArrow(
        dc,
        x0 + xOffset - arrowWidth * 2,
        y0 + (areaHeight / 2 - arrowHeight / 2),
        arrowWidth,
        arrowHeight,
        LEFT
      );

      if (i != numProblems - 1) {
        // Right
        drawArrow(
          dc,
          x0 + xOffset + areaWidth + arrowWidth,
          y0 + (areaHeight / 2 - arrowHeight / 2),
          arrowWidth,
          arrowHeight,
          RIGHT
        );
      }

      xOffset += fullWidth;
    }
  }

  private function drawFirstPage(
    dc as Gfx.Dc,
    x0 as Numeric,
    y0 as Numeric,
    width as Numeric,
    height as Numeric
  ) {
    var text = _warning.mainText;

    var font = Gfx.FONT_XTINY;

    var fitText = Gfx.fitTextToArea(text, font, width, height, true);

    dc.drawText(
      x0 + width / 2,
      y0 + height / 2,
      font,
      fitText,
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    );
  }

  private function drawArrow(
    dc as Gfx.Dc,
    x0 as Numeric,
    y0 as Numeric,
    width as Numeric,
    height as Numeric,
    direction as ArrowDirection
  ) {
    dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);

    if (direction == RIGHT) {
      dc.drawLine(x0, y0, x0 + width, y0 + height / 2);
      dc.drawLine(x0 + width, y0 + height / 2, x0, y0 + height);
    } else {
      dc.drawLine(x0 + width, y0, x0, y0 + height / 2);
      dc.drawLine(x0, y0 + height / 2, x0 + width, y0 + height);
    }
  }
}
