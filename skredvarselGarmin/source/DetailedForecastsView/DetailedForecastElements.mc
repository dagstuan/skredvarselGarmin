import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

public class DetailedForecastElements extends Ui.Drawable {
  private var _warning as DetailedAvalancheWarning;

  private var _y0 as Numeric;
  private var _height as Numeric;

  public var currentPage = 0;
  public var animationTime = 0;
  public var numElements as Number;

  private var _mainText as AvalancheUi.MainText?;
  private var _bufferedPages as Array<Gfx.BufferedBitmap?>;

  private var _seeFullForecastText as Ui.Resource?;

  public function initialize(
    warning as DetailedAvalancheWarning,
    y0 as Numeric,
    height as Numeric,
    seeFullForecastText as Ui.Resource
  ) {
    Drawable.initialize({});

    _y0 = y0;
    _height = height;

    _warning = warning;
    numElements = (warning["avalancheProblems"] as Array).size() + 1;

    _seeFullForecastText = seeFullForecastText;

    _bufferedPages = new [numElements];
  }

  public function onHide() {
    _mainText.onHide();
    _mainText = null;
    for (var i = 0; i < _bufferedPages.size(); i++) {
      _bufferedPages[i] = null;
    }
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

    drawFirstPage(dc, x0 + xOffset, y0, areaWidth, areaHeight);
    xOffset += fullWidth;

    for (var i = 0; i < numElements - 1; i++) {
      if (_bufferedPages[i] == null) {
        // Never rendered, render the page offscreen;
        var bufferedBitmap = $.newBufferedBitmap({
          :width => areaWidth,
          :height => areaHeight.toNumber(),
        });
        _bufferedPages[i] = bufferedBitmap;
        var bufferedDc = bufferedBitmap.getDc();

        // Other pages, map avalancheproblems
        // Minus one since we start rendering avalanche problems on page 2
        var problemToRender = avalancheProblems[i];

        var avalancheProblemUi = new AvalancheUi.AvalancheProblemUi({
          :problem => problemToRender,
          :locX => 0,
          :locY => 0,
          :width => areaWidth,
          :height => areaHeight,
        });
        avalancheProblemUi.draw(bufferedDc);
      }

      dc.drawBitmap(x0 + xOffset, y0, _bufferedPages[i]);

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
    if (_mainText == null) {
      _mainText = new AvalancheUi.MainText({
        :text => _warning["mainText"] + " " + _seeFullForecastText,
        :width => width,
        :height => height,
      });
    }

    _mainText.draw(dc, x0, y0);
  }
}
