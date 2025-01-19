import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Timer;

using AvalancheUi;

typedef DetailedForecastViewSettings as {
  :regionId as String,
  :index as Number,
  :numWarnings as Number,
  :warning as DetailedAvalancheWarning,
  :fetchedTime as Time.Moment,
};

class DetailedForecastView extends Ui.View {
  private const TICK_DURATION = 100;

  private var _warning as DetailedAvalancheWarning?;
  private var _isLoading as Boolean = false;
  private var _index as Number = 0;
  private var _numWarnings as Number = 0;
  private var _regionId as String;

  private var _width as Numeric?;
  private var _height as Numeric?;

  private var _headerHeight as Numeric = 0;
  private var _dangerLevelHeight as Numeric = 0;
  private var _mainContentHeight as Numeric = 0;
  private var _footerHeight as Numeric = 0;

  private var _mainContent as DetailedForecastElements?;
  private var _currentElement as Number = 0;
  private var _numElements as Number?;

  private var _pageIndicator as AvalancheUi.PageIndicator =
    new AvalancheUi.PageIndicator();
  private var _ticksBeforeAnimatePageIndicator = 25;

  private var _forecastElementsIndicator as
  AvalancheUi.ForecastElementsIndicator?;

  private var _dangerLevelBitmap as Gfx.BufferedBitmap?;
  private var _dangerLevelBitmapWidth as Numeric?;

  private var _header as DetailedForecastHeader?;
  private var _footer as DetailedForecastFooter?;

  private var _updateTimer as Timer.Timer?;

  public function initialize(settings as DetailedForecastViewSettings) {
    View.initialize();

    _regionId = settings[:regionId];

    setWarning(
      settings[:index],
      settings[:numWarnings],
      settings[:warning],
      settings[:fetchedTime]
    );
  }

  public function onShow() {
    _updateTimer = new Timer.Timer();
    _updateTimer.start(method(:onTick), TICK_DURATION /* ms */, true);
  }

  public function onTick() as Void {
    if (_footer != null) {
      _footer.onTick();
    }
    if (_mainContent != null) {
      _mainContent.onTick();
    }

    if (_ticksBeforeAnimatePageIndicator > 0) {
      _ticksBeforeAnimatePageIndicator -= 1;
    }

    if (_ticksBeforeAnimatePageIndicator == 0) {
      Ui.animate(
        _pageIndicator,
        :visibilityPercent,
        Ui.ANIM_TYPE_EASE_OUT,
        100,
        0,
        1,
        null
      );
      _ticksBeforeAnimatePageIndicator = -1;
    }

    Ui.requestUpdate();
  }

  public function onHide() {
    if (_updateTimer != null) {
      _updateTimer.stop();
      _updateTimer = null;
    }
    if (_mainContent != null) {
      _mainContent.onHide();
      _mainContent = null;
    }

    _footer = null;
    _dangerLevelBitmap = null;
  }

  public function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();

    _headerHeight = _height * 0.18;
    setupHeader(dc);

    _dangerLevelHeight = _height * 0.17; // 20% of screen
    setupDangerLevel(dc);

    _mainContentHeight = _height * 0.48;
    setupMainContent(dc);

    _footerHeight = _height * 0.17; // 15% of screen
    setupFooter(dc);
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    if (
      _header == null ||
      _dangerLevelBitmap == null ||
      _mainContent == null ||
      _footer == null
    ) {
      onLayout(dc);
    }

    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    _header.draw(dc);

    var dangerLevelY0 = _headerHeight;
    if ($.DrawOutlines) {
      $.drawOutline(dc, 0, dangerLevelY0, _width, _dangerLevelHeight);
    }

    dc.drawBitmap(
      _width / 2 - _dangerLevelBitmapWidth / 2,
      dangerLevelY0,
      _dangerLevelBitmap
    );

    var mainContentY0 = dangerLevelY0 + _dangerLevelHeight;
    _mainContent.draw(dc, mainContentY0);

    var footerY0 = mainContentY0 + _mainContentHeight;
    _footer.draw(dc, footerY0);

    _pageIndicator.draw(dc, _numWarnings, _index);

    _forecastElementsIndicator.draw(dc, _currentElement);
  }

  private function setupHeader(dc as Gfx.Dc) {
    var startValidity = (_warning["validity"] as Array)[0];
    var validityDate = $.parseDate(startValidity);

    _header = new DetailedForecastHeader({
      :dc => dc,
      :regionName => $.getRegionName(_regionId),
      :validityDate => $.getHumanReadableDateText(validityDate),
      :locY => 0,
      :locX => 0,
      :width => _width,
      :height => _headerHeight,
    });
  }

  private function setupDangerLevel(dc as Gfx.Dc) {
    var dangerLevel = _warning["dangerLevel"];
    var font = Gfx.FONT_MEDIUM;
    var paddingBetween = _width * 0.02;
    var iconResource = $.getIconResourceForDangerLevel(dangerLevel);
    var icon = WatchUi.loadResource(iconResource);
    var iconWidth = icon.getWidth();
    var iconHeight = icon.getHeight();

    var levelText = $.getOrLoadResourceString("Faregrad", :Level);
    var text = Lang.format("$1$ $2$", [levelText, dangerLevel]);

    var textWidth = dc.getTextWidthInPixels(text, font);
    var centerY0 = _dangerLevelHeight / 2;

    _dangerLevelBitmapWidth = iconWidth + paddingBetween + textWidth;
    _dangerLevelBitmap = $.newBufferedBitmap({
      :width => _dangerLevelBitmapWidth.toNumber(),
      :height => _dangerLevelHeight.toNumber(),
    });
    var bufferedDc = _dangerLevelBitmap.getDc();

    var color = colorize(_warning["dangerLevel"]);
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

  private function setupMainContent(dc as Gfx.Dc) {
    _mainContent = new DetailedForecastElements({
      :dc => dc,
      :warning => _warning,
      :height => _mainContentHeight,
      :fullWidth => _width,
    });
  }

  public function setupFooter(dc as Gfx.Dc) {
    _footer = new DetailedForecastFooter({
      :publishedTime => _warning["dangerLevel"] > 0
        ? _warning["published"]
        : null,
      :locX => 0,
      :width => _width,
      :height => _footerHeight,
      :isLoading => _isLoading,
    });
  }

  public function goToNextVisibleElement() {
    if (_mainContent != null) {
      _currentElement = _mainContent.goToNextElement();
    }
  }

  public function goToPreviousVisibleElement() {
    if (_mainContent != null) {
      _currentElement = _mainContent.goToPreviousElement();
    }
  }

  public function toggleVisibleElement() {
    if (_mainContent != null) {
      _currentElement = _mainContent.toggleVisibleElement();
    }
  }

  public function setIsLoading(isLoading as Boolean) {
    _isLoading = isLoading;
    if (_footer != null) {
      _footer.onUpdate(
        isLoading,
        _warning["dangerLevel"] > 0 ? _warning["published"] : null
      );
    }
  }

  public function setWarning(
    index as Number,
    numWarnings as Number,
    warning as DetailedAvalancheWarning,
    fetchedTime as Time.Moment
  ) {
    _index = index;
    _numWarnings = numWarnings;
    _warning = warning;

    _header = null;
    _dangerLevelBitmap = null;
    _dangerLevelBitmapWidth = null;
    _mainContent = null;
    _footer = null;

    _numElements = (_warning["avalancheProblems"] as Array).size() + 1;
    _forecastElementsIndicator = new AvalancheUi.ForecastElementsIndicator(
      _numElements
    );

    _currentElement = 0;
  }
}
