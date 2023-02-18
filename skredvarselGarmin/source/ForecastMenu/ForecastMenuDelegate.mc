import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class ForecastMenuInputDelegate extends Ui.Menu2InputDelegate {
  private var _skredvarselApi as SkredvarselApi;
  private var _skredvarselStorage as SkredvarselStorage;

  //! Constructor
  public function initialize(
    skredvarselApi as SkredvarselApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    Menu2InputDelegate.initialize();

    _skredvarselApi = skredvarselApi;
    _skredvarselStorage = skredvarselStorage;
  }

  //! Handle an item being selected
  //! @param item The selected menu item
  public function onSelect(item as Ui.CustomMenuItem) as Void {
    var id = item.getId();

    if (id.equals("edit")) {
      WatchUi.pushView(
        new EditMenu(_skredvarselStorage),
        new EditMenuDelegate(_skredvarselStorage),
        WatchUi.SLIDE_LEFT
      );
    } else {
      var regionId = (item as ForecastMenuItem).getRegionId();

      var view = new ForecastView(_skredvarselApi, regionId);

      WatchUi.pushView(
        view,
        new ForecastViewDelegate(view, _skredvarselStorage, regionId),
        WatchUi.SLIDE_LEFT
      );
    }

    WatchUi.requestUpdate();
  }
}
