import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

public class DetailedForecastElements extends Ui.Drawable {
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

  private var _bufferedPages as Array<Gfx.BufferedBitmap>;

  public function initialize(
    warning as DetailedAvalancheWarning,
    y0 as Numeric,
    height as Numeric
  ) {
    Drawable.initialize({});

    _y0 = y0;
    _height = height;

    _warning = warning;
    numPages = (warning["avalancheProblems"] as Array).size() + 1;

    _bufferedPages = new [numPages];
  }

  public function draw(dc as Gfx.Dc) {
    var fullWidth = dc.getWidth();

    $.drawOutline(dc, 0, _y0, fullWidth, _height);

    var areaWidth = Math.ceil(fullWidth * 0.75);
    var areaHeight = _height * 0.9;
    var x0 = fullWidth / 2 - areaWidth / 2;
    var y0 = _y0 + (_height / 2 - areaHeight / 2);

    $.drawOutline(dc, x0, y0, areaWidth, areaHeight);

    // TODO: This needs to be fixed if there is more than two pages.
    var xOffset =
      -(currentPage * fullWidth) - (animationTime / 1000.0) * fullWidth;

    $.drawOutline(dc, x0, y0 + areaHeight / 2, areaWidth, y0 + areaHeight / 2);

    var avalancheProblems = _warning["avalancheProblems"] as Array;

    for (var i = 0; i < numPages; i++) {
      var arrowHeight = Math.floor(areaHeight * 0.1);
      var arrowWidth = Math.floor(areaWidth * 0.02);

      var spaceLeft = arrowWidth * 2 + 1;
      var spaceRight = arrowWidth * 2 + 1;

      if (_bufferedPages[i] == null) {
        // Never rendered, render the page offscreen;
        var bufferedBitmap = $.newBufferedBitmap({
          :width => spaceLeft + areaWidth + spaceRight,
          :height => areaHeight.toNumber(),
        });
        _bufferedPages[i] = bufferedBitmap;
        var bufferedDc = bufferedBitmap.getDc();

        if (i == 0) {
          drawFirstPage(bufferedDc, spaceLeft, 0, areaWidth, areaHeight);

          // Draw next arrow for first page
          drawArrow(
            bufferedDc,
            spaceLeft + areaWidth + arrowWidth,
            areaHeight / 2 - arrowHeight / 2,
            arrowWidth,
            arrowHeight,
            RIGHT
          );
        } else {
          // Other pages, map avalancheproblems
          // Minus one since we start rendering avalanche problems on page 2
          var problemToRender = avalancheProblems[i - 1];

          var avalancheProblemUi = new AvalancheUi.AvalancheProblemUi({
            :problem => problemToRender,
            :locX => spaceLeft,
            :locY => 0,
            :width => areaWidth,
            :height => areaHeight,
          });
          avalancheProblemUi.draw(bufferedDc);

          // Arrows
          // Left
          drawArrow(
            bufferedDc,
            0,
            areaHeight / 2 - arrowHeight / 2,
            arrowWidth,
            arrowHeight,
            LEFT
          );

          if (i != numPages - 1) {
            // Right
            drawArrow(
              bufferedDc,
              spaceLeft + areaWidth + arrowWidth,
              areaHeight / 2 - arrowHeight / 2,
              arrowWidth,
              arrowHeight,
              RIGHT
            );
          }
        }
      }

      dc.drawBitmap(x0 + xOffset - spaceLeft, y0, _bufferedPages[i]);

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
    var text = _warning["mainText"];

    var font = Gfx.FONT_XTINY;

    var fitText = Gfx.fitTextToArea(text, font, width, height, true);

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
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
