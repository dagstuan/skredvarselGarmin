import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class ForecastViewMenuDelegate extends Ui.Menu2InputDelegate {
  private var _skredvarselStorage as SkredvarselStorage;
  private var _regionId as String;

  public function initialize(
    skredvarselStorage as SkredvarselStorage,
    regionId as String
  ) {
    Menu2InputDelegate.initialize();

    _skredvarselStorage = skredvarselStorage;
    _regionId = regionId;
  }

  public function onSelect(item as Ui.MenuItem) as Void {
    var id = item.getId();

    if (id.equals("setAsFavorite")) {
      _skredvarselStorage.toggleFavoriteRegion(_regionId);
      Ui.popView(Ui.SLIDE_RIGHT);
      Ui.requestUpdate();
    } else if (id.equals("remove")) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
      Ui.popView(Ui.SLIDE_RIGHT);
      _skredvarselStorage.removeSelectedRegion(_regionId);
      Ui.requestUpdate();
    }
  }
}
