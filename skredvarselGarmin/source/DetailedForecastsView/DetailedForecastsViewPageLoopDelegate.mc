import Toybox.Lang;

using Toybox.WatchUi as Ui;

typedef DetailedWarningsViewPageLoopDelegateSettings as {
  :index as Number,
  :view as DetailedForecastView,
  :regionId as String,
  :detailedWarnings as Array<DetailedAvalancheWarning>,
  :dataAge as Number,
};

class DetailedForecastViewPageLoopDelegate extends DetailedForecastViewDelegate {
  private var _index as Number;

  private var _detailedWarnings as Array<DetailedAvalancheWarning>;
  private var _dataAge as Number;

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
    _dataAge = settings[:dataAge];

    _numPages = _detailedWarnings.size();
  }

  //! Handle a physical button being pressed and released
  //! @param evt The key event that occurred
  //! @return true if handled, false otherwise
  public function onKey(evt as Ui.KeyEvent) as Boolean {
    DetailedForecastViewDelegate.onKey(evt);

    var key = evt.getKey();
    if (Ui.KEY_DOWN == key) {
      onNxtPage();
      return true;
    } else if (Ui.KEY_UP == key) {
      onPrevPage();
      return true;
    }
    return false;
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
    return false;
  }

  //! Go to the next page
  private function onNxtPage() as Void {
    _index = (_index + 1) % _numPages;
    var newView = getView();
    Ui.switchToView(newView, getDelegate(newView), Ui.SLIDE_UP);
  }

  //! Go to the previous page
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
    return new DetailedForecastView(
      _regionId,
      _index,
      _detailedWarnings.size(),
      _detailedWarnings[_index],
      _dataAge,
      true
    );
  }

  private function getDelegate(newView as DetailedForecastView) {
    return new DetailedForecastViewPageLoopDelegate({
      :index => _index,
      :view => newView,
      :detailedWarnings => _detailedWarnings,
      :regionId => _regionId,
      :dataAge => _dataAge,
    });
  }
}
