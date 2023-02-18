import Toybox.Lang;

using Toybox.WatchUi as Ui;

class ForecastViewDelegate extends Ui.BehaviorDelegate {
  private var _view as ForecastView;
  private var _regionId as String;
  private var _skredvarselStorage as SkredvarselStorage;

  public function initialize(
    view as ForecastView,
    skredvarselStorage as SkredvarselStorage,
    regionId as String
  ) {
    BehaviorDelegate.initialize();

    _view = view;
    _skredvarselStorage = skredvarselStorage;
    _regionId = regionId;
  }

  public function onMenu() {
    var menu = new ForecastViewMenu();

    var selectedRegionIds = _skredvarselStorage.getSelectedRegionIds();
    var favoriteRegionId = _skredvarselStorage.getFavoriteRegionId();

    var setAsFavoriteMenuItemText = favoriteRegionId.equals(_regionId)
      ? $.Rez.Strings.RemoveAsFavorite
      : $.Rez.Strings.SetAsFavorite;

    if (selectedRegionIds.size() > 1) {
      menu.addItem(
        new MenuItem(setAsFavoriteMenuItemText, null, "setAsFavorite", {})
      );
    }

    menu.addItem(new MenuItem($.Rez.Strings.Remove, null, "remove", {}));

    var delegate = new ForecastViewMenuDelegate(_skredvarselStorage, _regionId);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_BLINK);

    return true;
  }

  public function onSelect() as Boolean {
    // $.logMessage("Select!");
    _view.updateIndex();
    return true;
  }
}
