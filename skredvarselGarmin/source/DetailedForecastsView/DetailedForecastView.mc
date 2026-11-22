import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Time;
using Toybox.Timer;

using AvalancheUi;

// True if the latest touch was reported as a drag. Vertical swipes are then
// ignored, since DetailedForecastView.onDrag handles the touch. Global, since
// the swipe can arrive after a drag switched to another day's view.
var isLatestTouchDragged as Boolean = false;

enum DetailedForecastDragResult {
  DRAG_IGNORED,
  DRAG_HANDLED,
  DRAG_TO_NEXT_DAY,
  DRAG_TO_PREVIOUS_DAY,
}

typedef DetailedForecastViewSettings as {
  :regionId as String,
  :index as Number,
  :warnings as Array<DetailedAvalancheWarning>,
  :fetchedTime as Time.Moment,
};

class DetailedForecastView extends Ui.View {
  private const TICK_DURATION = 100;

  private enum DragMode {
    DRAG_MODE_NONE,
    DRAG_MODE_UNDECIDED,
    DRAG_MODE_TEXT,
    DRAG_MODE_PULL,
  }
  // Movement before a drag counts as horizontal or vertical.
  private const DRAG_SLOP = 8;
  // Releasing a pull at least this fast, in screens per second, flicks to the
  // next or previous day, even if it wasn't pulled far enough.
  private const FLICK_SPEED = 1.5;
  // The speed of a drag is measured over at least this long. Drag events
  // can come only a millisecond apart, too close to measure speed between.
  private const DRAG_SPEED_SAMPLE_MS = 100;

  private var _warning as DetailedAvalancheWarning?;
  private var _warnings as Array<DetailedAvalancheWarning>?;
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
  // Touch dragging, see onDrag. Where the text was scrolled when the drag
  // started on it, from 0 at the top to 1 at the bottom. Null if the drag
  // didn't start on text that scrolls.
  private var _dragStartScrollPosition as Float? = null;
  private var _dragMode as Number = DRAG_MODE_NONE;
  private var _dragStartX as Numeric = 0;
  private var _dragStartY as Numeric = 0;
  private var _lastDragY as Numeric = 0;
  // Where the finger was at two earlier times, at least
  // DRAG_SPEED_SAMPLE_MS apart, to measure how fast it moves.
  private var _dragSampleY as Numeric = 0;
  private var _dragSampleTime as Number = 0;
  private var _previousDragSampleY as Numeric = 0;
  private var _previousDragSampleTime as Number = 0;

  // How far the page is pulled to change day. Negative when pulled up, towards
  // the next day. Public, so it can be animated back.
  public var pullOffset as Numeric = 0;
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

    setWarning(settings[:index], settings[:warnings], settings[:fetchedTime]);
  }

  public function onShow() {
    _updateTimer = new Timer.Timer();
    _updateTimer.start(method(:onTick), TICK_DURATION /* ms */, true);
  }

  public function onTick() as Void {
    if (_header != null) {
      _header.onTick();
    }
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
    if (_header != null) {
      _header.onHide();
      _header = null;
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

    _header.draw(dc, pullOffset);

    var dangerLevelY0 = _headerHeight + pullOffset;
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

    if (pullOffset != 0) {
      drawPullTarget(dc);
    }

    _pageIndicator.draw(dc, _numWarnings, _index);

    _forecastElementsIndicator.draw(dc, _currentElement);
  }

  private function setupHeader(dc as Gfx.Dc) {
    var validityDate = $.getDisplayDateForWarning(_warning);

    _header = new DetailedForecastHeader({
      :dc => dc,
      :regionName => $.getRegionName(_regionId),
      :validityDate => $.getHumanReadableDateText(validityDate),
      :locY => 0,
      :locX => 0,
      :width => _width,
      :height => _headerHeight,
    });
    _header.onShow();
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
      :regionId => _regionId,
      :warnings => _warnings,
      :index => _index,
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

  // Touch dragging. A vertical drag that starts on text that scrolls drags
  // the text, unless the text is already at the end in that direction. Other
  // vertical drags pull the page towards the next or previous day, showing
  // that day at the edge, and change to it when released far enough.
  // Horizontal drags are left to the page swipes.
  public function onDrag(evt as Ui.DragEvent) as DetailedForecastDragResult {
    var coordinates = evt.getCoordinates();
    var x = coordinates[0];
    var y = coordinates[1];
    var type = evt.getType();

    if (type == Ui.DRAG_TYPE_START) {
      $.isLatestTouchDragged = true;
      _dragMode = DRAG_MODE_UNDECIDED;
      _dragSampleY = y;
      _dragSampleTime = System.getTimer();
      _previousDragSampleY = y;
      _previousDragSampleTime = _dragSampleTime;
      _dragStartX = x;
      _dragStartY = y;
      _lastDragY = y;

      var mainContentY0 = _headerHeight + _dangerLevelHeight;
      var isInMainContent =
        y >= mainContentY0 && y <= mainContentY0 + _mainContentHeight;
      _dragStartScrollPosition =
        _mainContent != null && isInMainContent
          ? _mainContent.getScrollPosition()
          : null;

      // Grabbing the page while it springs back.
      if (pullOffset != 0 && Ui has :cancelAllAnimations) {
        Ui.cancelAllAnimations();
      }
      return DRAG_IGNORED;
    }

    if (_dragMode == DRAG_MODE_UNDECIDED) {
      decideDragMode(x, y);
    }

    var dy = y - _lastDragY;
    _lastDragY = y;

    var now = System.getTimer();
    if (now - _dragSampleTime >= DRAG_SPEED_SAMPLE_MS) {
      _previousDragSampleY = _dragSampleY;
      _previousDragSampleTime = _dragSampleTime;
      _dragSampleY = y;
      _dragSampleTime = now;
    }
    if (_dragMode == DRAG_MODE_TEXT) {
      _mainContent.dragBy(dy);
    } else if (_dragMode == DRAG_MODE_PULL) {
      var maxPull = getPullThreshold() * 1.3;
      pullOffset = $.clamp(pullOffset + dy, -maxPull, maxPull);
    }
    Ui.requestUpdate();

    // Only handled when dragging, so taps and horizontal swipes still work.
    var result =
      _dragMode == DRAG_MODE_TEXT || _dragMode == DRAG_MODE_PULL
        ? DRAG_HANDLED
        : DRAG_IGNORED;
    if (type == Ui.DRAG_TYPE_STOP) {
      if (_dragMode == DRAG_MODE_PULL) {
        result = releasePull(getFlick(_previousDragSampleY - y, _height, now));
      }
      _dragMode = DRAG_MODE_NONE;
    }
    return result;
  }

  // 1 if the finger was flicked up, towards the next day, -1 if flicked down,
  // otherwise 0. moved is how far the finger moved up over the last 100 to
  // 200 ms, or since the start of a shorter drag, and screenSize the height
  // of the screen.
  private function getFlick(
    moved as Numeric,
    screenSize as Numeric,
    now as Number
  ) as Number {
    var elapsed = $.max([now - _previousDragSampleTime, 1]);
    var speed = (moved.toFloat() * 1000) / elapsed / screenSize;
    if (speed >= FLICK_SPEED) {
      return 1;
    } else if (speed <= -FLICK_SPEED) {
      return -1;
    }
    return 0;
  }

  private function decideDragMode(x as Numeric, y as Numeric) as Void {
    var dx = x - _dragStartX;
    var dy = y - _dragStartY;
    if (dx.abs() < DRAG_SLOP && dy.abs() < DRAG_SLOP) {
      return;
    }

    if (dx.abs() > dy.abs()) {
      _dragMode = DRAG_MODE_NONE;
    } else if (
      _dragStartScrollPosition != null &&
      (dy < 0 ? _dragStartScrollPosition < 1 : _dragStartScrollPosition > 0)
    ) {
      _dragMode = DRAG_MODE_TEXT;
    } else {
      _dragMode = DRAG_MODE_PULL;
    }
  }

  // Changes day if the page is pulled far enough or flicked the way it is
  // pulled, otherwise springs back. flick is as returned by getFlick.
  private function releasePull(flick as Number) as DetailedForecastDragResult {
    var isPulledUp = pullOffset < 0;
    if (
      pullOffset.abs() >= getPullThreshold() ||
      (flick > 0 && isPulledUp) ||
      (flick < 0 && pullOffset > 0)
    ) {
      return isPulledUp ? DRAG_TO_NEXT_DAY : DRAG_TO_PREVIOUS_DAY;
    }

    Ui.animate(
      self,
      :pullOffset,
      Ui.ANIM_TYPE_EASE_OUT,
      pullOffset,
      0,
      0.2,
      null
    );
    return DRAG_HANDLED;
  }

  // How far the page must be pulled to change day: until the whole pull
  // strip is visible, with some space to the edge of the screen. The strip
  // has a gap, two lines of text, a gap and the chevron, as in
  // drawPullTarget.
  private function getPullThreshold() as Numeric {
    return $.max([
      _height * 0.25,
      Gfx.getFontHeight(Gfx.FONT_XTINY) * (0.3 + 2 + 0.3 + 0.3 + 0.8),
    ]);
  }

  // The day the page is pulled towards, in the space it was pulled from.
  private function drawPullTarget(dc as Gfx.Dc) as Void {
    var isNextDay = pullOffset < 0;
    var targetIndex = isNextDay
      ? (_index + 1) % _numWarnings
      : (_index - 1 + _numWarnings) % _numWarnings;
    var target = _warnings[targetIndex];

    var areaHeight = pullOffset.abs();
    var areaY0 = isNextDay ? _height - areaHeight : 0;
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.fillRectangle(0, areaY0, _width, areaHeight);

    // The line and chevron turn white when releasing changes day.
    var edgeY = isNextDay ? areaY0 : areaHeight;
    dc.setColor(
      areaHeight >= getPullThreshold() ? Gfx.COLOR_WHITE : Gfx.COLOR_DK_GRAY,
      Gfx.COLOR_TRANSPARENT
    );
    dc.drawLine(0, edgeY, _width, edgeY);

    var font = Gfx.FONT_XTINY;
    var lineHeight = Gfx.getFontHeight(font);
    var gap = lineHeight * 0.3;

    var textY0 = isNextDay ? edgeY + gap : edgeY - gap - lineHeight * 2;

    // The chevron is on the far side of the text, pointing towards the edge
    // the day comes from: down below the next day, up above the previous day.
    var chevronBaseY = isNextDay ? textY0 + lineHeight * 2 + gap : textY0 - gap;
    var chevronTipY = chevronBaseY + lineHeight * 0.3 * (isNextDay ? 1 : -1);
    var chevronHalfWidth = lineHeight * 0.4;
    dc.setPenWidth(3);
    dc.drawLine(
      _width / 2 - chevronHalfWidth,
      chevronBaseY,
      _width / 2,
      chevronTipY
    );
    dc.drawLine(
      _width / 2,
      chevronTipY,
      _width / 2 + chevronHalfWidth,
      chevronBaseY
    );
    dc.setPenWidth(1);

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      _width / 2,
      textY0,
      font,
      $.getHumanReadableDateText($.getDisplayDateForWarning(target)),
      Gfx.TEXT_JUSTIFY_CENTER
    );

    var dangerLevel = target["dangerLevel"];
    dc.setColor($.colorize(dangerLevel), Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      _width / 2,
      textY0 + lineHeight,
      font,
      Lang.format("$1$ $2$", [
        $.getOrLoadResourceString("Faregrad", :Level),
        dangerLevel,
      ]),
      Gfx.TEXT_JUSTIFY_CENTER
    );
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
    warnings as Array<DetailedAvalancheWarning>,
    fetchedTime as Time.Moment
  ) {
    _index = index;
    _numWarnings = warnings.size();
    _warnings = warnings;
    _warning = warnings[index];

    _header = null;
    _dangerLevelBitmap = null;
    _dangerLevelBitmapWidth = null;
    _mainContent = null;
    _footer = null;

    _numElements = $.getNumDetailedForecastElements(
      _regionId,
      _warnings,
      _index
    );
    _forecastElementsIndicator = new AvalancheUi.ForecastElementsIndicator(
      _numElements
    );

    _currentElement = 0;
  }
}
