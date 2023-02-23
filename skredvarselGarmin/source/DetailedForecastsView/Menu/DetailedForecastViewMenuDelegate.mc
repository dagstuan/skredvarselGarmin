import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class DetailedForecastViewMenuDelegate extends Ui.Menu2InputDelegate {
  private var _regionId as String;

  public function initialize(regionId as String) {
    Menu2InputDelegate.initialize();
    _regionId = regionId;
  }

  public function onSelect(item as Ui.MenuItem) as Void {
    var id = item.getId();

    if (id.equals("setAsFavorite")) {
      $.toggleFavoriteRegion(_regionId);
      Ui.popView(Ui.SLIDE_RIGHT);
      Ui.requestUpdate();
    } else if (id.equals("remove")) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
      Ui.popView(Ui.SLIDE_RIGHT);
      $.removeSelectedRegion(_regionId);
      Ui.requestUpdate();
    }
  }
}
