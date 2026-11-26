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
  :regionId as String,
  :warnings as Array<DetailedAvalancheWarning>,
  :index as Number,
  :locY as Numeric,
  :height as Numeric,
  :fullWidth as Numeric,
};

(:noLimitedBackgroundMemory)
function hasText(text as String?) as Boolean {
  return text != null && text.length() > 0;
}

// [snowpack history parts, mountain weather parts] for the warning at index.
// Mountain weather is shown for the day and the day before it, newest first.
(:noLimitedBackgroundMemory)
function getTextSectionParts(
  regionId as String,
  warnings as Array<DetailedAvalancheWarning>,
  index as Number
) as [Array<AvalancheUi.TextSectionPart>, Array<AvalancheUi.TextSectionPart>] {
  var snowpackParts = [] as Array<AvalancheUi.TextSectionPart>;
  var weatherParts = [] as Array<AvalancheUi.TextSectionPart>;

  for (var i = index; i >= 0 && i >= index - 1; i--) {
    var texts = $.getDetailedWarningTexts(regionId, warnings, i);
    if (texts == null) {
      continue;
    }

    if (i == index && $.hasText(texts[0])) {
      snowpackParts.add([
        // Written when the forecast was published, like on varsom.no.
        $.getHumanReadableDateText($.parseDate(warnings[i]["published"])),
        texts[0],
      ]);
    }

    if ($.hasText(texts[1])) {
      weatherParts.add([
        $.getHumanReadableDateText($.getDisplayDateForWarning(warnings[i])),
        texts[1],
      ]);
    }
  }

  return [snowpackParts, weatherParts];
}

// Main text, one page per avalanche problem, then snowpack history and
// mountain weather when present.
(:noLimitedBackgroundMemory)
function getNumDetailedForecastElements(
  regionId as String,
  warnings as Array<DetailedAvalancheWarning>,
  index as Number
) as Number {
  var numElements =
    (warnings[index]["avalancheProblems"] as Array).size() + 1;
  var parts = $.getTextSectionParts(regionId, warnings, index);
  for (var i = 0; i < parts.size(); i++) {
    if (parts[i].size() > 0) {
      numElements += 1;
    }
  }
  return numElements;
}

(:limitedBackgroundMemory)
function getNumDetailedForecastElements(
  regionId as String,
  warnings as Array<DetailedAvalancheWarning>,
  index as Number
) as Number {
  return (warnings[index]["avalancheProblems"] as Array).size() + 1;
}

public class DetailedForecastElements {
  private const ANIMATION_TIME_SECONDS = 0.3;
  // How far, in pages, a page must be dragged sideways to change page,
  // unless it is flicked.
  private const DRAG_THRESHOLD = 0.25;

  private var _regionId as String;
  private var _warning as DetailedAvalancheWarning;
  private var _warnings as Array<DetailedAvalancheWarning>;
  private var _index as Number;

  private var _fullWidth as Numeric;

  private var _areaWidth as Numeric;
  private var _areaHeight as Numeric;
  private var _x0 as Numeric;

  // The pages loop. position is the horizontal scroll position in pages: 0
  // when the first page is shown, 1 for the second and so on. It follows the
  // finger when dragged, and is animated towards _target, the page being
  // moved to. Neither is wrapped around while moving, so going past the last
  // page moves on to page _numElements, which is drawn as the first page.
  // Public, so it can be animated.
  public var position as Float = 0.0;
  private var _target as Number = 0;
  private var _isAnimating as Boolean = false;
  // The page being moved to, wrapped around.
  private var _currentPage = 0;
  private var _numElements as Number;

  private var _elements as Array<AvalancheForecastElement?>;

  private var _seeFullForecastText as String =
    $.getForecastLanguage() == 1
      ? "Se komplett varsel på varsom.no"
      : "See complete forecast at varsom.no";

  public function initialize(settings as DetailedForecastElementsSettings) {
    _regionId = settings[:regionId];
    _warnings = settings[:warnings];
    _index = settings[:index];
    _warning = _warnings[_index];
    _fullWidth = settings[:fullWidth];

    _areaWidth = Math.ceil(_fullWidth * 0.84);
    _areaHeight = settings[:height];
    _x0 = _fullWidth / 2 - _areaWidth / 2;

    _numElements = $.getNumDetailedForecastElements(
      _regionId,
      _warnings,
      _index
    );
    _elements = new [_numElements];
    setupElements(settings[:dc]);

    var currentElement = _elements[_currentPage];
    if (currentElement != null) {
      currentElement.onShow();
    }
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

  // Each of these returns the page being moved to.
  public function goToNextElement() as Number {
    finishAnimation();
    return goToElement(_target + 1);
  }

  public function goToPreviousElement() as Number {
    finishAnimation();
    return goToElement(_target - 1);
  }

  // Touch dragging sideways: true if there are other pages to drag to.
  public function canDragSideways() as Boolean {
    return _numElements > 1;
  }

  // Moves the pages by dx with the finger, at most one page either way.
  public function dragSidewaysBy(dx as Numeric) as Void {
    position = $.clamp(
      position - dx.toFloat() / _fullWidth,
      _target - 1,
      _target + 1
    );
  }

  // Moves to the page dragged towards if it was dragged far enough or
  // flicked the same way, otherwise back to the current page. flick is 1 if
  // flicked towards the next page, -1 towards the previous, otherwise 0.
  public function releaseSidewaysDrag(flick as Number) as Number {
    var dragged = position - _target;
    if (dragged >= DRAG_THRESHOLD || (flick > 0 && dragged > 0)) {
      return goToNextElement();
    } else if (dragged <= -DRAG_THRESHOLD || (flick < 0 && dragged < 0)) {
      return goToPreviousElement();
    }
    animateToTarget();
    return _currentPage;
  }

  // Finishes a running page animation at once, so a drag can start from a
  // page at rest.
  public function finishAnimation() as Void {
    if (_isAnimating && Ui has :cancelAllAnimations) {
      Ui.cancelAllAnimations();
    }
  }

  // True while the pages are dragged or animated.
  private function isMoving() as Boolean {
    return position != _target.toFloat();
  }

  // For dragging the visible element's text on touch screens. Null if it
  // has no text that scrolls, otherwise how far it is scrolled, from 0 at the
  // top to 1 at the bottom.
  public function getScrollPosition() as Float? {
    var element = _elements[_currentPage];
    if (!isMoving() && element != null && element has :getScrollPosition) {
      return element.getScrollPosition();
    }
    return null;
  }

  // Moves the visible element's text by dy, and pauses its auto scroll for a
  // while.
  public function dragBy(dy as Numeric) as Void {
    var element = _elements[_currentPage];
    if (element != null && element has :dragBy) {
      element.dragBy(dy);
    }
  }

  private function goToElement(target as Number) as Number {
    if (_numElements < 2) {
      return _currentPage;
    }

    var newPage = ((target % _numElements) + _numElements) % _numElements;
    if (newPage != _currentPage) {
      var prevElement = _elements[_currentPage];
      if (prevElement != null) {
        prevElement.onHide();
      }
      var newElement = _elements[newPage];
      if (newElement != null) {
        newElement.onShow();
      }
    }

    _target = target;
    _currentPage = newPage;
    animateToTarget();
    return _currentPage;
  }

  private function animateToTarget() as Void {
    _isAnimating = true;
    Ui.animate(
      self,
      :position,
      Ui.ANIM_TYPE_EASE_OUT,
      position,
      _target,
      ANIMATION_TIME_SECONDS,
      method(:onAnimationComplete)
    );
  }

  // Wraps the position back around once at rest.
  public function onAnimationComplete() as Void {
    _isAnimating = false;
    if (!isMoving()) {
      _target = _currentPage;
      position = _currentPage.toFloat();
    }
    Ui.requestUpdate();
  }

  private function setupElements(dc as Gfx.Dc) {
    var avalancheProblems = _warning["avalancheProblems"] as Array;
    var numProblems = avalancheProblems.size();

    _elements[0] = new AvalancheUi.MainText({
      :dc => dc,
      :text => getMainText(),
      :emergencyWarning => _warning["emergencyWarning"],
      :width => _areaWidth,
      :height => _areaHeight,
    });

    for (var i = 0; i < numProblems; i++) {
      _elements[i + 1] = new AvalancheUi.AvalancheProblemUi({
        :dc => dc,
        :problem => avalancheProblems[i],
        :width => _areaWidth,
        :height => _areaHeight,
      });
    }

    setupTextElements(dc, numProblems + 1);
  }

  // Snowpack history and mountain weather pages, starting at nextIndex.
  (:noLimitedBackgroundMemory)
  private function setupTextElements(dc as Gfx.Dc, nextIndex as Number) {
    var parts = $.getTextSectionParts(_regionId, _warnings, _index);
    var titles = [
      $.getOrLoadResourceString("Snødekkehistorikk", :SnowpackHistory),
      $.getOrLoadResourceString("Fjellvær", :MountainWeather),
    ];

    for (var i = 0; i < parts.size(); i++) {
      if (parts[i].size() > 0) {
        _elements[nextIndex] = new AvalancheUi.TextSection({
          :dc => dc,
          :title => titles[i],
          :parts => parts[i],
          :width => _areaWidth,
          :height => _areaHeight,
        });
        nextIndex += 1;
      }
    }
  }

  (:limitedBackgroundMemory)
  private function setupTextElements(dc as Gfx.Dc, nextIndex as Number) {}

  public function draw(dc as Gfx.Dc, y0 as Numeric) {
    if ($.DrawOutlines) {
      $.drawOutline(dc, _x0, y0, _areaWidth, _areaHeight);
    }

    // Draws the pages that are on screen, in pages from the position,
    // wrapped around so the last page is next to the first.
    var half = _numElements / 2.0;
    for (var i = 0; i < _numElements; i++) {
      var pagesAway = i - position;
      while (pagesAway > half) {
        pagesAway -= _numElements;
      }
      while (pagesAway <= -half) {
        pagesAway += _numElements;
      }
      if (pagesAway.abs() < 1) {
        _elements[i].draw(dc, _x0 + pagesAway * _fullWidth, y0);
      }
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

    if (length == 0) {
      return $.getOrLoadResourceString(
        "Ingen varseltekst tilgjengelig.",
        :NoForecastText
      );
    }

    // Add a dot if it's not there in the main text.
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

    return mainText;
  }
}
