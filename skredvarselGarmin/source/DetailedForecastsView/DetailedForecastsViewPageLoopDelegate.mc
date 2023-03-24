import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian;
using Toybox.Time;

typedef DetailedWarningsViewPageLoopDelegateSettings as {
  :index as Number,
  :view as DetailedForecastView,
  :regionId as String,
  :detailedWarnings as Array<DetailedAvalancheWarning>,
  :fetchedTime as Time.Moment,
};

class DetailedForecastViewPageLoopDelegate extends DetailedForecastViewDelegate {
  private var _index as Number;

  private var _detailedWarnings as Array<DetailedAvalancheWarning>;
  private var _fetchedTime as Time.Moment;

  private var _numPages as Numeric;

  public function initialize(
    settings as DetailedWarningsViewPageLoopDelegateSettings
  ) {
    DetailedForecastViewDelegate.initialize({
      :view => settings[:view],
      :regionId => settings[:regionId],
    });

    _index = settings[:index];
    _detailedWarnings = settings[:detailedWarnings];
    _fetchedTime = settings[:fetchedTime];

    _numPages = _detailedWarnings.size();

    var dataAge = Time.now().compare(_fetchedTime);
    if (dataAge > $.TIME_TO_CONSIDER_DATA_STALE) {
      if ($.Debug) {
        $.logMessage("Stale forecast, try to reload in background");
      }

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

      _view.setWarning(_detailedWarnings[_index], _fetchedTime);

      Ui.requestUpdate();
    }
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
    _index = (_index + 1) % _numPages;
    var newView = getView();
    Ui.switchToView(newView, getDelegate(newView), Ui.SLIDE_UP);
  }

  private function onPrevPage() as Void {
    _index -= 1;
    if (_index < 0) {
      _index = _numPages - 1;
    }
    _index = _index % _numPages;
    var newView = getView();
    Ui.switchToView(newView, getDelegate(newView), Ui.SLIDE_DOWN);
  }

  private function getView() as DetailedForecastView {
    return new DetailedForecastView({
      :regionId => _regionId,
      :index => _index,
      :numWarnings => _detailedWarnings.size(),
      :warning => _detailedWarnings[_index],
      :fetchedTime => _fetchedTime,
    });
  }

  private function getDelegate(newView as DetailedForecastView) {
    return new DetailedForecastViewPageLoopDelegate({
      :index => _index,
      :view => newView,
      :detailedWarnings => _detailedWarnings,
      :regionId => _regionId,
      :fetchedTime => _fetchedTime,
    });
  }
}
