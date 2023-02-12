import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class ForecastMenuInputDelegate extends Ui.Menu2InputDelegate {
  //! Constructor
  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  //! Handle an item being selected
  //! @param item The selected menu item
  public function onSelect(item as ForecastMenuItem) as Void {
    System.println("select!");
    WatchUi.pushView(
      new ForecastView(item.getRegionId()),
      null,
      WatchUi.SLIDE_UP
    );
    WatchUi.requestUpdate();
  }

  //! Handle the back key being pressed
  public function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }

  public function onNextPage() as Boolean {
    System.println("nextpage!");
    return true;
  }

  public function onPreviousPage() as Boolean {
    System.println("prevpage!");
    return true;
  }
}
