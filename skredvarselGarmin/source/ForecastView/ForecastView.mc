import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastView extends Ui.View {
  private const ANIMATION_TIME_SECONDS = 0.3;

  private var _skredvarselApi as SkredvarselApi;
  private var _regionId as String;
  private var _warning as DetailedAvalancheWarning?;

  private var _width as Numeric?;
  private var _height as Numeric?;

  private var _progressBar as Ui.ProgressBar?;

  private var _viewPages as ForecastViewPages?;
  private var _currentPage as Number = 0;

  public function initialize(
    skredvarselApi as SkredvarselApi,
    regionId as String
  ) {
    View.initialize();

    _skredvarselApi = skredvarselApi;
    _regionId = regionId;
  }

  public function onShow() {
    if (_warning == null) {
      _skredvarselApi.loadDetailedWarningForRegion(
        _regionId,
        method(:onReceive)
      );

      var loadingText = Ui.loadResource($.Rez.Strings.Loading);

      _progressBar = new Ui.ProgressBar(loadingText, null);
      Ui.pushView(_progressBar, new ProgressDelegate(), Ui.SLIDE_BLINK);
    }
  }

  public function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    if (_warning != null) {
      drawCircle(dc);
      drawTitle(dc);
      drawHeaderAndDangerLevel(dc);

      if (_viewPages == null) {
        _viewPages = new ForecastViewPages(_warning);
      }

      _viewPages.currentPage = _currentPage;
      _viewPages.draw(dc);
    }
  }

  private function drawCircle(dc as Gfx.Dc) {
    var circleWidth = 4;
    var paddingFromEdge = 5;
    var color = colorize(_warning.dangerLevel);

    dc.setColor(color, color);
    dc.setPenWidth(circleWidth);
    dc.drawCircle(
      _width / 2 - 1,
      _height / 2 - 1,
      _width / 2 - paddingFromEdge
    );
  }

  private function drawTitle(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);

    var regionName = $.Regions[_regionId];
    dc.drawText(
      _width / 2,
      Graphics.getFontHeight(Graphics.FONT_XTINY) + 5,
      Graphics.FONT_XTINY,
      regionName,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  private function drawHeaderAndDangerLevel(dc as Gfx.Dc) {
    var font = Graphics.FONT_MEDIUM;
    var y0 = _height * 0.2;
    var paddingBetween = 10;
    var iconResource = $.getIconResourceForDangerLevel(_warning.dangerLevel);
    var icon = WatchUi.loadResource(iconResource);
    var iconWidth = icon.getWidth();

    var text = "Level " + _warning.dangerLevel.toString();

    var textWidth = dc.getTextWidthInPixels(text, font);
    var totalWidth = iconWidth + paddingBetween + textWidth;

    var x0 = _width / 2 - totalWidth / 2;

    dc.drawText(x0, y0, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawBitmap(x0 + iconWidth * 2 + paddingBetween, y0, icon);
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
