import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time as Time;
using Toybox.Time.Gregorian;

public class ForecastView extends Ui.View {
  private const TIME_TO_CONSIDER_STALE = Gregorian.SECONDS_PER_HOUR * 2;
  private const TIME_TO_SHOW_LOADING = Gregorian.SECONDS_PER_DAY;
  private const ANIMATION_TIME_SECONDS = 0.3;

  private var _skredvarselApi as SkredvarselApi;
  private var _regionId as String;
  private var _warning as DetailedAvalancheWarning?;
  private var _warningFetchedTime as Time.Moment?;

  private var _width as Numeric?;
  private var _height as Numeric?;

  private var _deviceScreenWidth as Numeric;

  private var _progressBar as Ui.ProgressBar?;

  private var _viewPages as ForecastViewPages?;
  private var _currentPage as Number = 0;

  private var _loadingText as Ui.Resource?;
  private var _todayText as Ui.Resource?;
  private var _levelText as Ui.Resource?;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    regionId as String
  ) {
    View.initialize();

    _skredvarselApi = skredvarselApi;
    _regionId = regionId;

    _deviceScreenWidth = $.getDeviceScreenWidth();
  }

  public function onShow() {
    _todayText = Ui.loadResource($.Rez.Strings.Today);
    _levelText = Ui.loadResource($.Rez.Strings.Level);

    getWarningFromCache();
    if (
      _warning == null ||
      Time.now().compare(_warningFetchedTime) > TIME_TO_SHOW_LOADING
    ) {
      // Har ikke warning. Vis loading.
      _loadingText = Ui.loadResource($.Rez.Strings.Loading);
      _progressBar = new Ui.ProgressBar(_loadingText, null);
      Ui.pushView(_progressBar, new ProgressDelegate(), Ui.SLIDE_BLINK);

      _skredvarselApi.loadDetailedWarningForRegion(
        _regionId,
        method(:onReceive)
      );
    } else if (
      Time.now().compare(_warningFetchedTime) > TIME_TO_CONSIDER_STALE
    ) {
      $.logMessage("Stale forecast, try to reload in background");

      _skredvarselApi.loadDetailedWarningForRegion(
        _regionId,
        method(:onReceive)
      );

      // Har warning, men den er stale. Vis bildet og last i bakgrunnen.
    }
  }

  private function getWarningFromCache() as Void {
    var data = _skredvarselApi.getDetailedWarningForRegion(_regionId);

    if (data != null) {
      _warning = new DetailedAvalancheWarning(data[0]);
      _warningFetchedTime = new Time.Moment(data[1]);
    }
  }

  public function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    if (_warning != null) {
      drawCircle(dc);

      var titleAreaY0 = 0;
      var titleAreaHeight = _height * 0.18; // 15% of screen

      drawSingleLineTextArea(
        dc,
        titleAreaY0,
        titleAreaHeight,
        $.Regions[_regionId]
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

      drawSingleLineTextArea(dc, footerY0, footerHeight, _todayText);
    }
  }

  public function onHide() {
    _loadingText = null;
    _todayText = null;
    _levelText = null;
  }

  private function drawCircle(dc as Gfx.Dc) {
    var circleWidth = 3;
    var paddingFromEdge = 4;
    var color = colorize(_warning.dangerLevel);

    dc.setColor(color, color);
    dc.setPenWidth(circleWidth);
    dc.drawCircle(
      _width / 2 - 1,
      _height / 2 - 1,
      _width / 2 - paddingFromEdge
    );
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

    var font = Gfx.FONT_MEDIUM;
    var paddingBetween = _width * 0.02;
    var iconResource = $.getIconResourceForDangerLevel(_warning.dangerLevel);
    var icon = WatchUi.loadResource(iconResource);
    var iconWidth = icon.getWidth();
    var iconHeight = icon.getHeight();

    var text = _levelText + " " + _warning.dangerLevel.toString();

    var textWidth = dc.getTextWidthInPixels(text, font);
    var contentWidth = iconWidth + paddingBetween + textWidth;

    var x0 = _width / 2 - contentWidth / 2;
    var centerY0 = y0 + height / 2;

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
    if (_viewPages == null) {
      _viewPages = new ForecastViewPages(_warning, y0, height);
    }

    _viewPages.currentPage = _currentPage;
    _viewPages.draw(dc);
  }

  public function onReceive(data) as Void {
    if (_progressBar != null) {
      Ui.popView(Ui.SLIDE_BLINK);
    }
    _warning = new DetailedAvalancheWarning(data);
    Ui.requestUpdate();
  }

  public function updateIndex() {
    if (_viewPages == null) {
      return;
    }

    var offset = _currentPage == _viewPages.numPages - 1 ? 1 : -1;
    _currentPage = (_currentPage + 1) % _viewPages.numPages;
    _viewPages.animationTime = 1000 * offset;
    Ui.animate(
      _viewPages,
      :animationTime,
      Ui.ANIM_TYPE_EASE_IN_OUT,
      _viewPages.animationTime,
      0,
      ANIMATION_TIME_SECONDS,
      method(:animateComplete)
    );
  }

  function animateComplete() as Void {
    _viewPages.animationTime = 0;

    Ui.requestUpdate();
  }
}
