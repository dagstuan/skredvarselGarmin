import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

typedef AvalancheForecastElement as interface {
  function onShow() as Void;
  function onHide() as Void;
  function onTick() as Void;
  function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void;
};

typedef DetailedForecastElementsSettings as {
  :dc as Gfx.Dc,
  :warning as DetailedAvalancheWarning,
  :locY as Numeric,
  :height as Numeric,
  :fullWidth as Numeric,
};

public class DetailedForecastElements {
  private const ANIMATION_TIME_SECONDS = 0.3;
  private const ANIMATION_STEPS = ANIMATION_TIME_SECONDS * 60; // 60 FPS

  private var _warning as DetailedAvalancheWarning;

  private var _fullWidth as Numeric;

  private var _areaWidth as Numeric;
  private var _areaHeight as Numeric;
  private var _x0 as Numeric;

  public var animationTime = 0;
  private var _animating = false;
  private var _currentPage = 0;
  private var _previousPage = -1;
  private var _numElements as Number;

  private var _elements as Array<AvalancheForecastElement?>;

  private var _seeFullForecastText as String =
    $.getForecastLanguage() == 1
      ? "Se komplett varsel på varsom.no"
      : "See complete forecast at varsom.no";

  public function initialize(settings as DetailedForecastElementsSettings) {
    _warning = settings[:warning];
    _fullWidth = settings[:fullWidth];

    _areaWidth = Math.ceil(_fullWidth * 0.84);
    _areaHeight = settings[:height];
    _x0 = _fullWidth / 2 - _areaWidth / 2;

    _numElements = (_warning["avalancheProblems"] as Array).size() + 1;
    _elements = new [_numElements];
    setupElements(settings[:dc]);
  }

  public function onHide() {
    for (var i = 0; i < _elements.size(); i++) {
      if (_elements[i] != null) {
        _elements[i].onHide();
        _elements[i] = null;
      }
    }
  }

  public function onTick() {
    for (var i = 0; i < _elements.size(); i++) {
      if (_elements[i] != null) {
        _elements[i].onTick();
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

  public function pageAnimateComplete() as Void {
    _animating = false;
    animationTime = 0;
    Ui.requestUpdate();
  }

  private function setupElements(dc as Gfx.Dc) {
    var avalancheProblems = _warning["avalancheProblems"] as Array;

    for (var i = 0; i < _elements.size(); i++) {
      if (i == 0) {
        var mainText = new AvalancheUi.MainText({
          :dc => dc,
          :text => getMainText(),
          :emergencyWarning => _warning["emergencyWarning"],
          :width => _areaWidth,
          :height => _areaHeight,
        });

        _elements[i] = mainText;
      } else {
        var problemUi = new AvalancheUi.AvalancheProblemUi({
          :dc => dc,
          :problem => avalancheProblems[i - 1],
          :width => _areaWidth,
          :height => _areaHeight,
        });

        _elements[i] = problemUi;
      }
    }
  }

  public function draw(dc as Gfx.Dc, y0 as Numeric) {
    if ($.DrawOutlines) {
      $.drawOutline(dc, _x0, y0, _areaWidth, _areaHeight);
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

    for (var i = 0; i < _elements.size(); i++) {
      _elements[i].draw(dc, _x0 + xOffset, y0);
      if (_currentPage == i) {
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
    var length = mainText.length();
    while (mainText.substring(length - 1, length).equals(" ")) {
      mainText = mainText.substring(0, length - 1);
      length = mainText.length();
    }

    // Add a dot if it's not there in the main text.
    if (length > 0) {
      var lastChar = mainText.substring(length - 1, length);

      mainText = Lang.format("$1$$2$", [
        mainText,
        lastChar.equals(".") || lastChar.equals("!") || lastChar.equals("?")
          ? ""
          : ".",
      ]);

      if (!_warning["isTendency"] && _warning["dangerLevel"] > 0) {
        mainText = Lang.format("$1$ $2$", [mainText, _seeFullForecastText]);
      }
    }

    return mainText;
  }
}
