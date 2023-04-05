import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
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

// TODO: Draw header with buffered bitmaps.
class DetailedForecastView extends Ui.View {
  private const TICK_DURATION = 100;

  private var _warning as DetailedAvalancheWarning?;
  private var _fetchedTime as Time.Moment?;
  private var _isLoading as Boolean;

  private var _regionId as String;
  private var _index as Number;

  private var _width as Numeric?;
  private var _height as Numeric?;

  private var _todayText as Ui.Resource?;
  private var _yesterdayText as Ui.Resource?;
  private var _tomorrowText as Ui.Resource?;
  private var _levelText as Ui.Resource?;

  private var _elements as DetailedForecastElements?;
  private var _currentElement as Number = 0;
  private var _numElements as Number?;

  private var _pageIndicator as AvalancheUi.PageIndicator;
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
    _index = settings[:index];
    _isLoading = false;

    setWarning(settings[:warning], settings[:fetchedTime]);

    _pageIndicator = new AvalancheUi.PageIndicator(settings[:numWarnings]);
  }

  public function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  public function onShow() {
    _todayText = $.getOrLoadResourceString("I dag", :Today);
    _yesterdayText = $.getOrLoadResourceString("I går", :Yesterday);
    _tomorrowText = $.getOrLoadResourceString("I morgen", :Tomorrow);
    _levelText = $.getOrLoadResourceString("Faregrad", :Level);

    _updateTimer = new Timer.Timer();
    _updateTimer.start(method(:onTick), TICK_DURATION /* ms */, true);
  }

  public function onTick() as Void {
    if (_footer != null) {
      _footer.onTick();
    }
    if (_elements != null) {
      _elements.onTick();
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
    if (_elements != null) {
      _elements.onHide();
      _elements = null;
    }
    _todayText = null;
    _yesterdayText = null;
    _tomorrowText = null;
    _levelText = null;

    _footer = null;
    _dangerLevelBitmap = null;
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    var headerY0 = 0;
    var headerHeight = _height * 0.18; // 15% of screen
    drawHeader(dc, headerY0, headerHeight);

    var dangerLevelY0 = headerY0 + headerHeight;
    var dangerLevelHeight = _height * 0.17; // 20% of screen

    drawDangerLevel(dc, dangerLevelY0, dangerLevelHeight);

    var mainContentY0 = dangerLevelY0 + dangerLevelHeight;
    var mainContentHeight = _height * 0.48; // Half screen

    drawMainContent(dc, mainContentY0, mainContentHeight);

    var footerY0 = mainContentY0 + mainContentHeight;
    var footerHeight = _height * 0.17; // 15% of screen

    drawFooter(dc, footerY0, footerHeight);

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

  public function drawHeader(dc as Gfx.Dc, y0 as Numeric, height as Numeric) {
    if (_header == null) {
      var startValidity = (_warning["validity"] as Array)[0];
      var validityDate = $.parseDate(startValidity);

      _header = new DetailedForecastHeader({
        :regionName => $.getRegionName(_regionId),
        :validityDate => getDateText(validityDate),
        :locY => y0,
        :locX => 0,
        :width => _width,
        :height => height,
      });
    }

    _header.draw(dc);
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
      var dangerLevel = _warning["dangerLevel"];
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
        :warning => _warning,
        :locY => y0,
        :height => height,
        :fullWidth => _width,
      });
    }

    _elements.draw(dc);
  }

  public function drawFooter(dc as Gfx.Dc, y0 as Numeric, height as Numeric) {
    if (_footer == null) {
      _footer = new DetailedForecastFooter({
        :fetchedTime => _fetchedTime,
        :locY => y0,
        :locX => 0,
        :width => _width,
        :height => height,
        :isLoading => _isLoading,
      });
    }

    _footer.draw(dc);
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

  public function setIsLoading(isLoading as Boolean) {
    _isLoading = isLoading;
    if (_footer != null) {
      _footer.setIsLoading(isLoading);
    }
  }

  public function setWarning(
    warning as DetailedAvalancheWarning,
    fetchedTime as Time.Moment
  ) {
    _warning = warning;
    _fetchedTime = fetchedTime;

    _header = null;
    _dangerLevelBitmap = null;
    _dangerLevelBitmapWidth = null;
    _elements = null;
    _footer = null;

    _numElements = (_warning["avalancheProblems"] as Array).size() + 1;
    _forecastElementsIndicator = new AvalancheUi.ForecastElementsIndicator(
      _numElements
    );
    _currentElement = 0;
  }
}
