import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.Timer;

using AvalancheUi;

class DetailedForecastView extends Ui.View {
  private const ANIMATION_TIME_SECONDS = 0.3;
  private const TIME_TO_CONSIDER_STALE = Gregorian.SECONDS_PER_HOUR * 2;

  private var _regionId as String;
  private var _warning as DetailedAvalancheWarning?;
  private var _warningAge as Number;
  private var _index as Number;

  private var _width as Numeric?;
  private var _height as Numeric?;
  private var _deviceScreenWidth as Numeric;

  private var _todayText as Ui.Resource?;
  private var _yesterdayText as Ui.Resource?;
  private var _tomorrowText as Ui.Resource?;
  private var _levelText as Ui.Resource?;
  private var _seeFullForecastText as Ui.Resource?;

  private var _elements as DetailedForecastElements?;
  private var _currentElement as Number = 0;
  private var _numElements as Number?;

  private var _pageIndicator as AvalancheUi.PageIndicator;
  private var _animatePageIndicatorTimer as Timer.Timer?;

  private var _forecastElementsIndicator as
  AvalancheUi.ForecastElementsIndicator?;

  public function initialize(
    regionId as String,
    index as Number,
    numWarnings as Number,
    warning as DetailedAvalancheWarning,
    warningAge as Number
  ) {
    View.initialize();

    _regionId = regionId;
    _index = index;
    _warningAge = warningAge;

    setWarning(warning);

    if (_warningAge > TIME_TO_CONSIDER_STALE) {
      $.logMessage("Stale forecast, try to reload in background");

      $.loadDetailedWarningsForRegion(regionId, method(:onReceive));
    }

    _pageIndicator = new AvalancheUi.PageIndicator(numWarnings);

    _deviceScreenWidth = $.getDeviceScreenWidth();
  }

  function setWarning(warning as DetailedAvalancheWarning) {
    _warning = warning;
    _numElements = (warning["avalancheProblems"] as Array).size() + 1;
    _forecastElementsIndicator = new AvalancheUi.ForecastElementsIndicator(
      _numElements
    );
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200 && data != null) {
      setWarning((data as Array)[_index] as DetailedAvalancheWarning);
      _warningAge = 0;
      Ui.requestUpdate();
    }
  }

  public function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();

    _animatePageIndicatorTimer = new Timer.Timer();
    _animatePageIndicatorTimer.start(
      method(:animatePageIndicatorTimerCallback),
      2500,
      false
    );
  }

  function animatePageIndicatorTimerCallback() as Void {
    Ui.animate(
      _pageIndicator,
      :visibilityPercent,
      Ui.ANIM_TYPE_EASE_OUT,
      100,
      0,
      1,
      null
    );
    _animatePageIndicatorTimer = null;
  }

  public function onShow() {
    _todayText = Ui.loadResource($.Rez.Strings.Today);
    _yesterdayText = Ui.loadResource($.Rez.Strings.Yesterday);
    _tomorrowText = Ui.loadResource($.Rez.Strings.Tomorrow);
    _levelText = Ui.loadResource($.Rez.Strings.Level);
    _seeFullForecastText = Ui.loadResource($.Rez.Strings.SeeFullForecast);
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    var titleAreaY0 = 0;
    var titleAreaHeight = _height * 0.18; // 15% of screen

    drawSingleLineTextArea(
      dc,
      titleAreaY0,
      titleAreaHeight,
      $.getRegions()[_regionId]
    );

    var headerAndDangerLevelY0 = titleAreaY0 + titleAreaHeight;
    var headerAndDangerLevelHeight = _height * 0.17; // 20% of screen

    drawHeaderAndDangerLevel(
      dc,
      headerAndDangerLevelY0,
      headerAndDangerLevelHeight
    );

    var mainContentY0 = headerAndDangerLevelY0 + headerAndDangerLevelHeight;
    var mainContentHeight = _height * 0.48; // Half screen

    drawMainContent(dc, mainContentY0, mainContentHeight);

    var footerY0 = mainContentY0 + mainContentHeight;
    var footerHeight = _height * 0.17; // 15% of screen

    var startValidity = (_warning["validity"] as Array)[0];
    var validityDate = $.parseDate(startValidity);

    drawSingleLineTextArea(
      dc,
      footerY0,
      footerHeight,
      getDateText(validityDate)
    );

    _pageIndicator.draw(dc, _index);
    _forecastElementsIndicator.draw(dc, _currentElement);
  }

  function getDateText(date as Time.Moment) {
    var info = Gregorian.info(date, Time.FORMAT_SHORT);

    if ($.isToday(info)) {
      return _todayText;
    } else if ($.isYesterday(info)) {
      return _yesterdayText;
    } else if ($.isTomorrow(info)) {
      return _tomorrowText;
    } else {
      var validityInfo = Gregorian.info(date, Time.FORMAT_MEDIUM);

      return Lang.format("$1$ $2$", [validityInfo.day, validityInfo.month]);
    }
  }

  public function onHide() {
    if (_animatePageIndicatorTimer != null) {
      _animatePageIndicatorTimer.stop();
    }
    if (_elements != null) {
      _elements.onHide();
      _elements = null;
    }
    _animatePageIndicatorTimer = null;
    _todayText = null;
    _yesterdayText = null;
    _tomorrowText = null;
    _levelText = null;
    _seeFullForecastText = null;
  }

  private function drawSingleLineTextArea(
    dc as Gfx.Dc,
    y0 as Numeric,
    height as Numeric,
    text as String
  ) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    var font = Gfx.FONT_XTINY;
    var fontHeight = Gfx.getFontHeight(font);

    $.drawOutline(dc, 0, y0, _width, height);

    var textY0 = y0 + height / 2;
    var width = $.getScreenWidthAtPoint(_deviceScreenWidth, textY0);

    var fitText = Gfx.fitTextToArea(text, font, width, fontHeight, true);

    dc.drawText(
      _width / 2,
      textY0,
      Gfx.FONT_XTINY,
      fitText,
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    );
  }

  private function drawHeaderAndDangerLevel(
    dc as Gfx.Dc,
    y0 as Numeric,
    height as Numeric
  ) {
    $.drawOutline(dc, 0, y0, _width, height);

    var dangerLevel = _warning["dangerLevel"];
    var font = Gfx.FONT_MEDIUM;
    var paddingBetween = _width * 0.02;
    var iconResource = $.getIconResourceForDangerLevel(dangerLevel);
    var icon = WatchUi.loadResource(iconResource);
    var iconWidth = icon.getWidth();
    var iconHeight = icon.getHeight();

    var text = _levelText + " " + dangerLevel.toString();

    var textWidth = dc.getTextWidthInPixels(text, font);
    var contentWidth = iconWidth + paddingBetween + textWidth;

    var x0 = _width / 2 - contentWidth / 2;
    var centerY0 = y0 + height / 2;

    var color = colorize(_warning["dangerLevel"]);
    dc.setColor(color, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      x0,
      centerY0,
      font,
      text,
      Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
    );
    dc.drawBitmap(
      x0 + textWidth + paddingBetween,
      centerY0 - iconHeight / 2,
      icon
    );
  }

  private function drawMainContent(
    dc as Gfx.Dc,
    y0 as Numeric,
    height as Numeric
  ) {
    if (_elements == null) {
      _elements = new DetailedForecastElements(
        _warning,
        y0,
        height,
        _seeFullForecastText
      );
    }

    _elements.currentPage = _currentElement;
    _elements.draw(dc);
  }

  public function updateIndex() {
    if (_elements == null) {
      return;
    }

    var offset = _currentElement == _elements.numElements - 1 ? 1 : -1;
    _currentElement = (_currentElement + 1) % _elements.numElements;
    _elements.animationTime = 1000 * offset;
    Ui.animate(
      _elements,
      :animationTime,
      Ui.ANIM_TYPE_EASE_IN_OUT,
      _elements.animationTime,
      0,
      ANIMATION_TIME_SECONDS,
      method(:pageAnimateComplete)
    );
  }

  function pageAnimateComplete() as Void {
    _elements.animationTime = 0;

    Ui.requestUpdate();
  }
}
