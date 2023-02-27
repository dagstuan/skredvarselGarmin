import Toybox.Lang;

using Toybox.WatchUi as Ui;

typedef DetailedWarningsViewDelegateSettings as {
  :view as DetailedForecastView,
  :regionId as String,
};

class DetailedForecastViewDelegate extends Ui.BehaviorDelegate {
  hidden var _view as DetailedForecastView;
  hidden var _regionId as String;

  public function initialize(settings as DetailedWarningsViewDelegateSettings) {
    BehaviorDelegate.initialize();

    _view = settings[:view];
    _regionId = settings[:regionId];
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

  public function onSwipe(evt as Ui.SwipeEvent) as Boolean {
    var direction = evt.getDirection();
    if (direction == Ui.SWIPE_RIGHT) {
      _view.goToPreviousVisibleElement();
      return true;
    } else if (direction == Ui.SWIPE_LEFT) {
      _view.goToNextVisibleElement();
      return true;
    }
    return false;
  }

  //! Handle a physical button being pressed and released
  //! @param evt The key event that occurred
  //! @return true if handled, false otherwise
  public function onKey(evt as Ui.KeyEvent) as Boolean {
    var key = evt.getKey();
    if (Ui.KEY_ENTER == key) {
      _view.toggleVisibleElement();
      return true;
    }
    return false;
  }
}
