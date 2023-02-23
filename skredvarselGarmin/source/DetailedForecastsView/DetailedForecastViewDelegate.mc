import Toybox.Lang;

using Toybox.WatchUi as Ui;

typedef DetailedWarningsViewDelegateSettings as {
  :detailedForecastApi as DetailedForecastApi,
  :index as Number,
  :view as DetailedForecastView,
  :regionId as String,
  :detailedWarnings as Array<DetailedAvalancheWarning>,
  :dataAge as Number,
};

class DetailedForecastViewDelegate extends Ui.BehaviorDelegate {
  private var _index as Number;

  private var _detailedForecastApi as DetailedForecastApi;
  private var _view as DetailedForecastView;
  private var _regionId as String;
  private var _detailedWarnings as Array<DetailedAvalancheWarning>;
  private var _dataAge as Number;

  private var _numPages as Numeric;

  public function initialize(settings as DetailedWarningsViewDelegateSettings) {
    BehaviorDelegate.initialize();

    _detailedForecastApi = settings[:detailedForecastApi];
    _index = settings[:index];
    _detailedWarnings = settings[:detailedWarnings];
    _view = settings[:view];
    _regionId = settings[:regionId];
    _dataAge = settings[:dataAge];

    _numPages = _detailedWarnings.size();
  }

  public function onMenu() {
    var menu = new DetailedForecastViewMenu();

    var selectedRegionIds = $.getSelectedRegionIds();
    var favoriteRegionId = $.getFavoriteRegionId();

    var setAsFavoriteMenuItemText = favoriteRegionId.equals(_regionId)
      ? $.Rez.Strings.RemoveAsFavorite
      : $.Rez.Strings.SetAsFavorite;

    if (selectedRegionIds.size() > 1) {
      menu.addItem(
        new MenuItem(setAsFavoriteMenuItemText, null, "setAsFavorite", {})
      );
    }

    menu.addItem(new MenuItem($.Rez.Strings.Remove, null, "remove", {}));

    var delegate = new DetailedForecastViewMenuDelegate(_regionId);

    Ui.pushView(menu, delegate, Ui.SLIDE_BLINK);

    return true;
  }

  public function onSelect() as Boolean {
    // $.logMessage("Select!");
    _view.updateIndex();
    return true;
  }

  //! Handle a physical button being pressed and released
  //! @param evt The key event that occurred
  //! @return true if handled, false otherwise
  public function onKey(evt as Ui.KeyEvent) as Boolean {
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
      _detailedForecastApi,
      _regionId,
      _index,
      _detailedWarnings[_index],
      _dataAge
    );
  }

  private function getDelegate(newView as DetailedForecastView) {
    return new DetailedForecastViewDelegate({
      :index => _index,
      :view => newView,
      :detailedWarnings => _detailedWarnings,
      :regionId => _regionId,
      :dataAge => _dataAge,
    });
  }
}
