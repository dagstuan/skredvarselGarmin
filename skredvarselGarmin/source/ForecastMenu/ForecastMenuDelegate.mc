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

      WatchUi.pushView(
        new ForecastView(_skredvarselApi, regionId),
        new ForecastViewDelegate(_skredvarselStorage, regionId),
        WatchUi.SLIDE_UP
      );
    }

    WatchUi.requestUpdate();
  }

  //! Handle the back key being pressed
  public function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
