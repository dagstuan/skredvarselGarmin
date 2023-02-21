import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class ForecastMenuInputDelegate extends Ui.Menu2InputDelegate {
  private var _detailedForecastApi as DetailedForecastApi;
  private var _skredvarselStorage as SkredvarselStorage;

  //! Constructor
  public function initialize(
    skredvarselApi as DetailedForecastApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    Menu2InputDelegate.initialize();

    _detailedForecastApi = skredvarselApi;
    _skredvarselStorage = skredvarselStorage;
  }

  //! Handle an item being selected
  //! @param item The selected menu item
  public function onSelect(item as Ui.CustomMenuItem) as Void {
    var id = item.getId();

    if (id.equals("edit")) {
      WatchUi.pushView(
        new EditMenu(),
        new EditMenuDelegate(_skredvarselStorage),
        WatchUi.SLIDE_LEFT
      );
    } else {
      var regionId = (item as ForecastMenuItem).getRegionId();

      var view = new ForecastView(_detailedForecastApi, regionId);

      WatchUi.pushView(
        view,
        new ForecastViewDelegate(view, _skredvarselStorage, regionId),
        WatchUi.SLIDE_LEFT
      );
    }

    WatchUi.requestUpdate();
  }
}
