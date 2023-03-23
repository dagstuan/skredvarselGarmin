import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;

using AvalancheUi;

typedef AvalancheForecastElement as interface {
  function onShow() as Void;
  function onHide() as Void;
  function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void;
};

typedef DetailedForecastElementsSettings as {
  :warning as DetailedAvalancheWarning,
  :locY as Numeric,
  :height as Numeric,
  :fullWidth as Numeric,
};

public class DetailedForecastElements {
  private const ANIMATION_TIME_SECONDS = 0.3;
  private const ANIMATION_STEPS = ANIMATION_TIME_SECONDS * 60; // 60 FPS

  private var _warning as DetailedAvalancheWarning;

  private var _locY as Numeric;
  private var _height as Numeric;
  private var _fullWidth as Numeric;

  private var _areaWidth as Numeric;
  private var _areaHeight as Numeric;
  private var _x0 as Numeric;
  private var _y0 as Numeric;

  public var animationTime = 0;
  private var _animating = false;
  private var _currentPage = 0;
  private var _previousPage = -1;
  private var _numElements as Number;

  private var _elements as Array<AvalancheForecastElement?>;

  private var _seeFullForecastText as Ui.Resource?;

  public function initialize(settings as DetailedForecastElementsSettings) {
    _warning = settings[:warning];
    _locY = settings[:locY];
    _height = settings[:height];
    _fullWidth = settings[:fullWidth];

    _areaWidth = Math.ceil(_fullWidth * 0.75);
    _areaHeight = _height * 0.9;
    _x0 = _fullWidth / 2 - _areaWidth / 2;
    _y0 = _locY + (_height / 2 - _areaHeight / 2);

    _numElements = (_warning["avalancheProblems"] as Array).size() + 1;

    var forecastLanguage = $.getForecastLanguage();
    _seeFullForecastText =
      forecastLanguage == 1
        ? "Se komplett varsel på www.varsom.no"
        : "See complete forecast at www.varsom.no";

    _elements = new [_numElements];
  }

  public function onHide() {
    for (var i = 0; i < _elements.size(); i++) {
      if (_elements[i] != null) {
        _elements[i].onHide();
        _elements[i] = null;
      }
    }
  }

  public function goToNextElement() as Number {
    if (_currentPage == _numElements - 1) {
      return _currentPage;
    }

    setPage(_currentPage + 1);
    animateToVisibleElement();
    return _currentPage;
  }

  public function goToPreviousElement() as Number {
    if (_currentPage == 0) {
      return _currentPage;
    }

    setPage(_currentPage - 1);
    animateToVisibleElement();
    return _currentPage;
  }

  public function toggleVisibleElement() as Number {
    setPage((_currentPage + 1) % _numElements);
    animateToVisibleElement();
    return _currentPage;
  }

  private function setPage(newPage as Number) {
    var prevPage = _currentPage;
    _currentPage = newPage;
    _previousPage = prevPage;

    var prevElement = _elements[_previousPage];
    if (prevElement != null) {
      prevElement.onHide();
    }

    var currElement = _elements[_currentPage];
    if (currElement != null) {
      currElement.onShow();
    }
  }

  private function animateToVisibleElement() as Void {
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
  }

  function pageAnimateComplete() as Void {
    _animating = false;
    animationTime = 0;
    Ui.requestUpdate();
  }

  public function draw(dc as Gfx.Dc) {
    if ($.DrawOutlines) {
      $.drawOutline(dc, 0, _locY, _fullWidth, _height);

      $.drawOutline(dc, _x0, _y0, _areaWidth, _areaHeight);
    }

    var xOffset = -(_currentPage * _fullWidth);

    if (_animating) {
      var direction = _currentPage > _previousPage ? 1 : -1;
      var diff = ((_currentPage - _previousPage) * _fullWidth).abs();

      if (direction > 0) {
        xOffset =
          -_previousPage * _fullWidth -
          (animationTime / ANIMATION_STEPS) * diff;
      } else {
        xOffset =
          -_previousPage * _fullWidth +
          (animationTime / ANIMATION_STEPS) * diff;
      }
    }

    var avalancheProblems = _warning["avalancheProblems"] as Array;

    for (var i = 0; i < _elements.size(); i++) {
      var wasNull = _elements[i] == null;
      if (wasNull) {
        if (i == 0) {
          _elements[i] = new AvalancheUi.MainText({
            :text => getMainText(),
            :width => _areaWidth,
            :height => _areaHeight,
          });
        } else {
          _elements[i] = new AvalancheUi.AvalancheProblemUi({
            :problem => avalancheProblems[i - 1],
            :width => _areaWidth,
            :height => _areaHeight,
          });
        }
      }

      _elements[i].draw(dc, _x0 + xOffset, _y0);
      if (wasNull && _currentPage == i) {
        _elements[i].onShow();
      }
      xOffset += _fullWidth;
    }
  }

  function getMainText() {
    var mainText = _warning["mainText"];

    if (mainText == null) {
      mainText = "";
    }

    // Remove all spaces from the end.
    while (
      mainText.substring(mainText.length() - 1, mainText.length()).equals(" ")
    ) {
      mainText = mainText.substring(0, mainText.length() - 1);
    }

    // Add a dot if it's not there in the main text.
    if (
      mainText.length() > 0 &&
      !mainText.substring(mainText.length() - 1, mainText.length()).equals(".")
    ) {
      mainText += ".";
    }

    return mainText + " " + _seeFullForecastText;
  }
}
