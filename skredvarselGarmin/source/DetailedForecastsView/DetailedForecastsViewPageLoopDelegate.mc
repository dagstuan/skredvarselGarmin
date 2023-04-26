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
    if (dataAge > $.TIME_TO_CONSIDER_DATA_STALE && $.canMakeWebRequest()) {
      $.log("Stale forecast, try to reload in background");

      _view.setIsLoading(true);
      $.loadDetailedWarningsForRegion(settings[:regionId], method(:onReceive));
    }
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
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
          _visibleDate = $.parseDate(_detailedWarnings[index]["validity"][0]);
        }
      }

      _view.setWarning(
        index,
        _detailedWarnings.size(),
        _detailedWarnings[index],
        _fetchedTime
      );
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

  public function onSwipe(evt as Ui.SwipeEvent) as Boolean {
    var direction = evt.getDirection();
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
    var newVisibleDate = $.addDays(_visibleDate, 1);

    var newIndex = $.getDateIndexForDetailedWarnings(
      _detailedWarnings,
      newVisibleDate
    );

    if (newIndex == -1) {
      // Loop around
      newIndex = 0;
      _visibleDate = $.parseDate(_detailedWarnings[newIndex]["validity"][0]);
    } else {
      _visibleDate = newVisibleDate;
    }

    var newView = getView(newIndex);
    Ui.switchToView(newView, getDelegate(newView), Ui.SLIDE_UP);
  }

  private function onPrevPage() as Void {
    var newVisibleDate = $.subtractDays(_visibleDate, 1);

    var newIndex = $.getDateIndexForDetailedWarnings(
      _detailedWarnings,
      newVisibleDate
    );

    if (newIndex == -1) {
      // Loop around
      newIndex = _detailedWarnings.size() - 1;
      _visibleDate = $.parseDate(_detailedWarnings[newIndex]["validity"][0]);
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
      :numWarnings => _detailedWarnings.size(),
      :warning => _detailedWarnings[index],
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
