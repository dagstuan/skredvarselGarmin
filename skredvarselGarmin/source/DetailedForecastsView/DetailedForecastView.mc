import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.Timer;

using AvalancheUi;

// TODO: Draw header and footer with buffered bitmaps.
class DetailedForecastView extends Ui.View {
  public var warning as DetailedAvalancheWarning?;

  private var _regionId as String;
  private var _index as Number;

  private var _width as Numeric?;
  private var _height as Numeric?;
  private var _deviceScreenWidth as Numeric;

  private var _todayText as Ui.Resource?;
  private var _yesterdayText as Ui.Resource?;
  private var _tomorrowText as Ui.Resource?;
  private var _levelText as Ui.Resource?;

  private var _elements as DetailedForecastElements?;
  private var _currentElement as Number = 0;
  private var _numElements as Number?;

  private var _pageIndicator as AvalancheUi.PageIndicator?;
  private var _animatePageIndicatorTimer as Timer.Timer?;

  private var _forecastElementsIndicator as
  AvalancheUi.ForecastElementsIndicator?;

  private var _dangerLevelBitmap as Gfx.BufferedBitmap?;
  private var _dangerLevelBitmapWidth as Numeric?;

  public function initialize(
    regionId as String,
    index as Number,
    numWarnings as Number,
    warning as DetailedAvalancheWarning,
    showPageIndicator as Boolean
  ) {
    View.initialize();

    _regionId = regionId;
    _index = index;
    self.warning = warning;
    _numElements = (warning["avalancheProblems"] as Array).size() + 1;
    _forecastElementsIndicator = new AvalancheUi.ForecastElementsIndicator(
      _numElements
    );

    if (showPageIndicator) {
      _pageIndicator = new AvalancheUi.PageIndicator(numWarnings);
    }

    _deviceScreenWidth = $.getDeviceScreenWidth();
  }

  public function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();

    if (_pageIndicator != null) {
      _animatePageIndicatorTimer = new Timer.Timer();
      _animatePageIndicatorTimer.start(
        method(:animatePageIndicatorTimerCallback),
        2500,
        false
      );
    }
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
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    var titleAreaY0 = 0;
    var titleAreaHeight = _height * 0.18; // 15% of screen

    var startValidity = (warning["validity"] as Array)[0];
    var validityDate = $.parseDate(startValidity);
    drawSingleLineTextArea(
      dc,
      titleAreaY0,
      titleAreaHeight,
      getDateText(validityDate)
    );

    var dangerLevelY0 = titleAreaY0 + titleAreaHeight;
    var dangerLevelHeight = _height * 0.17; // 20% of screen

    drawDangerLevel(dc, dangerLevelY0, dangerLevelHeight);

    var mainContentY0 = dangerLevelY0 + dangerLevelHeight;
    var mainContentHeight = _height * 0.48; // Half screen

    drawMainContent(dc, mainContentY0, mainContentHeight);

    var footerY0 = mainContentY0 + mainContentHeight;
    var footerHeight = _height * 0.17; // 15% of screen

    drawSingleLineTextArea(
      dc,
      footerY0,
      footerHeight,
      $.getRegions()[_regionId]
    );

    if (_pageIndicator != null) {
      _pageIndicator.draw(dc, _index);
    }

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

    _dangerLevelBitmap = null;
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

    if ($.DrawOutlines) {
      $.drawOutline(dc, 0, y0, _width, height);
    }

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

  private function drawDangerLevel(
    dc as Gfx.Dc,
    y0 as Numeric,
    height as Numeric
  ) {
    if ($.DrawOutlines) {
      $.drawOutline(dc, 0, y0, _width, height);
    }

    if (_dangerLevelBitmap == null) {
      var dangerLevel = warning["dangerLevel"];
      var font = Gfx.FONT_MEDIUM;
      var paddingBetween = _width * 0.02;
      var iconResource = $.getIconResourceForDangerLevel(dangerLevel);
      var icon = WatchUi.loadResource(iconResource);
      var iconWidth = icon.getWidth();
      var iconHeight = icon.getHeight();

      var text = _levelText + " " + dangerLevel.toString();

      var textWidth = dc.getTextWidthInPixels(text, font);
      var centerY0 = height / 2;

      _dangerLevelBitmapWidth = iconWidth + paddingBetween + textWidth;
      _dangerLevelBitmap = $.newBufferedBitmap({
        :width => _dangerLevelBitmapWidth,
        :height => height,
      });
      var bufferedDc = _dangerLevelBitmap.getDc();

      var color = colorize(warning["dangerLevel"]);
      bufferedDc.setColor(color, Gfx.COLOR_TRANSPARENT);
      bufferedDc.drawText(
        0,
        centerY0,
        font,
        text,
        Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
      );
      bufferedDc.drawBitmap(
        textWidth + paddingBetween,
        centerY0 - iconHeight / 2,
        icon
      );
    }

    dc.drawBitmap(
      _width / 2 - _dangerLevelBitmapWidth / 2,
      y0,
      _dangerLevelBitmap
    );
  }

  private function drawMainContent(
    dc as Gfx.Dc,
    y0 as Numeric,
    height as Numeric
  ) {
    if (_elements == null) {
      _elements = new DetailedForecastElements({
        :warning => warning,
        :locY => y0,
        :height => height,
        :fullWidth => _width,
      });
    }

    _elements.draw(dc);
  }

  public function goToNextVisibleElement() {
    if (_elements == null) {
      return;
    }

    _currentElement = _elements.goToNextElement();
  }

  public function goToPreviousVisibleElement() {
    if (_elements == null) {
      return;
    }

    _currentElement = _elements.goToPreviousElement();
  }

  public function toggleVisibleElement() {
    if (_elements == null) {
      return;
    }

    _currentElement = _elements.toggleVisibleElement();
  }
}
