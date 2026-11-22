import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Time;

typedef DetailedWarningsViewPageLoopDelegateSettings as {
  :visibleDate as Time.Moment,
  :view as DetailedForecastView,
  :regionId as String,
  :detailedWarnings as Array<DetailedAvalancheWarning>,
  :fetchedTime as Time.Moment,
};

class DetailedForecastViewPageLoopDelegate extends DetailedForecastViewDelegate {
  private var _visibleDate as Time.Moment;

  private var _detailedWarnings as Array<DetailedAvalancheWarning>;
  private var _fetchedTime as Time.Moment;

  // A pull changes day both when released and when the system reports the
  // same touch as a swipe. Both can reach this delegate before the new view
  // is shown, so only the first one changes day.
  private var _hasChangedPage as Boolean = false;

  public function initialize(
    settings as DetailedWarningsViewPageLoopDelegateSettings
  ) {
    DetailedForecastViewDelegate.initialize({
      :view => settings[:view],
      :regionId => settings[:regionId],
    });

    _visibleDate = settings[:visibleDate];
    _detailedWarnings = settings[:detailedWarnings];
    _fetchedTime = settings[:fetchedTime];

    var dataAge = Time.now().compare(_fetchedTime);

    // Memory constrained devices only fetch a single day in the background, refetch since we are in foreground now.
    var numWarnings = _detailedWarnings.size();

    if (
      (dataAge > $.TIME_TO_CONSIDER_DATA_STALE || numWarnings <= 1) &&
      $.canMakeWebRequest()
    ) {
      if ($.Debug) {
        $.log("Stale forecast, try to reload in background");
      }

      _view.setIsLoading(true);
      $.loadDetailedWarningsForRegion(
        settings[:regionId],
        method(:onReceive),
        true
      );
    }
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    if (responseCode == 200 && data != null) {
      _detailedWarnings = data as Array;
      _fetchedTime = Time.now();

      var index = $.getDateIndexForDetailedWarnings(
        _detailedWarnings,
        _visibleDate
      );

      if (index == -1) {
        // Visible date is not part of received data.
        _visibleDate = $.getStartDateForDetailedWarnings();
        index = $.getDateIndexForDetailedWarnings(
          _detailedWarnings,
          _visibleDate
        );

        if (index == -1) {
          // Still cant find the damn index.
          index = 0;
          _visibleDate = $.getDisplayDateForWarning(_detailedWarnings[index]);
        }
      }

      _view.setWarning(index, _detailedWarnings, _fetchedTime);
    }

    _view.setIsLoading(false);

    Ui.requestUpdate();
  }

  public function onKey(evt as Ui.KeyEvent) as Boolean {
    var key = evt.getKey();
    if (Ui.KEY_DOWN == key) {
      onNxtPage();
      return true;
    } else if (Ui.KEY_UP == key) {
      onPrevPage();
      return true;
    }
    return DetailedForecastViewDelegate.onKey(evt);
  }

  public function onDrag(evt as Ui.DragEvent) as Boolean {
    var result = _view.onDrag(evt);
    if (result == DRAG_TO_NEXT_DAY) {
      onNxtPage();
    } else if (result == DRAG_TO_PREVIOUS_DAY) {
      onPrevPage();
    }
    return result != DRAG_IGNORED;
  }

  public function onSwipe(evt as Ui.SwipeEvent) as Boolean {
    var direction = evt.getDirection();
    var isVertical = direction == Ui.SWIPE_UP || direction == Ui.SWIPE_DOWN;
    if (isVertical && $.isLatestTouchDragged) {
      // Vertical touches are handled by onDrag. A quick flick that pulled the
      // page changes day though, even if it didn't pull far enough.
      if (!_view.isPulledInSwipeDirection(direction)) {
        return true;
      }
    }

    if (direction == Ui.SWIPE_UP) {
      onNxtPage();
      return true;
    } else if (direction == Ui.SWIPE_DOWN) {
      onPrevPage();
      return true;
    }
    return DetailedForecastViewDelegate.onSwipe(evt);
  }

  private function onNxtPage() as Void {
    if (_hasChangedPage) {
      return;
    }
    _hasChangedPage = true;

    var newVisibleDate = $.addDays(_visibleDate, 1);

    var newIndex = $.getDateIndexForDetailedWarnings(
      _detailedWarnings,
      newVisibleDate
    );

    if (newIndex == -1) {
      // Loop around
      newIndex = 0;
      _visibleDate = $.getDisplayDateForWarning(_detailedWarnings[newIndex]);
    } else {
      _visibleDate = newVisibleDate;
    }

    var newView = getView(newIndex);
    Ui.switchToView(newView, getDelegate(newView), Ui.SLIDE_UP);
  }

  private function onPrevPage() as Void {
    if (_hasChangedPage) {
      return;
    }
    _hasChangedPage = true;

    var newVisibleDate = $.subtractDays(_visibleDate, 1);

    var newIndex = $.getDateIndexForDetailedWarnings(
      _detailedWarnings,
      newVisibleDate
    );

    if (newIndex == -1) {
      // Loop around
      newIndex = _detailedWarnings.size() - 1;
      _visibleDate = $.getDisplayDateForWarning(_detailedWarnings[newIndex]);
    } else {
      _visibleDate = newVisibleDate;
    }

    var newView = getView(newIndex);
    Ui.switchToView(newView, getDelegate(newView), Ui.SLIDE_DOWN);
  }

  private function getView(index as Number) as DetailedForecastView {
    return new DetailedForecastView({
      :regionId => _regionId,
      :index => index,
      :warnings => _detailedWarnings,
      :fetchedTime => _fetchedTime,
    });
  }

  private function getDelegate(newView as DetailedForecastView) {
    return new DetailedForecastViewPageLoopDelegate({
      :visibleDate => _visibleDate,
      :view => newView,
      :detailedWarnings => _detailedWarnings,
      :regionId => _regionId,
      :fetchedTime => _fetchedTime,
    });
  }
}
