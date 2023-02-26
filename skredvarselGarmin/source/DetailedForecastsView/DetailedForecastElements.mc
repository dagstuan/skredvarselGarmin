import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;

using AvalancheUi;

public class DetailedForecastElements extends Ui.Drawable {
  private const ANIMATION_TIME_SECONDS = 0.3;
  private const ANIMATION_STEPS = ANIMATION_TIME_SECONDS * 60; // 60 FPS

  private var _warning as DetailedAvalancheWarning;

  private var _y0 as Numeric;
  private var _height as Numeric;

  public var animationTime = 0;
  private var _animating = false;
  private var _currentPage = 0;
  private var _previousPage = -1;
  private var _numElements as Number;

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
    _numElements = (warning["avalancheProblems"] as Array).size() + 1;

    _seeFullForecastText = seeFullForecastText;

    _bufferedPages = new [_numElements];
  }

  public function onHide() {
    _mainText.onHide();
    _mainText = null;
    for (var i = 0; i < _bufferedPages.size(); i++) {
      _bufferedPages[i] = null;
    }
  }

  public function changePage() as Number {
    var prevPage = _currentPage;
    _currentPage = (_currentPage + 1) % _numElements;
    _previousPage = prevPage;
    _animating = true;

    Ui.animate(
      self,
      :animationTime,
      Ui.ANIM_TYPE_EASE_IN_OUT,
      0,
      ANIMATION_STEPS,
      ANIMATION_TIME_SECONDS,
      method(:pageAnimateComplete)
    );

    return _currentPage;
  }

  function pageAnimateComplete() as Void {
    _animating = false;
    animationTime = 0;
    Ui.requestUpdate();
  }

  public function draw(dc as Gfx.Dc) {
    var fullWidth = dc.getWidth();

    $.drawOutline(dc, 0, _y0, fullWidth, _height);

    var areaWidth = Math.ceil(fullWidth * 0.75);
    var areaHeight = _height * 0.9;
    var x0 = fullWidth / 2 - areaWidth / 2;
    var y0 = _y0 + (_height / 2 - areaHeight / 2);

    $.drawOutline(dc, x0, y0, areaWidth, areaHeight);

    var xOffset = -(_currentPage * fullWidth);

    if (_animating) {
      var direction = _currentPage > _previousPage ? 1 : -1;
      var diff = ((_currentPage - _previousPage) * fullWidth).abs();

      if (direction > 0) {
        xOffset =
          -_previousPage * fullWidth - (animationTime / ANIMATION_STEPS) * diff;
      } else {
        xOffset =
          -_previousPage * fullWidth + (animationTime / ANIMATION_STEPS) * diff;
      }
    }

    $.drawOutline(dc, x0, y0 + areaHeight / 2, areaWidth, y0 + areaHeight / 2);

    var avalancheProblems = _warning["avalancheProblems"] as Array;

    drawFirstPage(dc, x0 + xOffset, y0, areaWidth, areaHeight);
    xOffset += fullWidth;

    for (var i = 0; i < _numElements - 1; i++) {
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
