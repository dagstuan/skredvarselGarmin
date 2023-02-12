using Toybox.System;
using Toybox.WatchUi as Ui;

public class EditMenuDelegate extends Ui.Menu2InputDelegate {
  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  //! Handle an item being selected
  //! @param item The selected menu item
  public function onSelect(item as EditMenuItem) as Void {
    System.println(
      "select! " + item.getId() + " isEnabled: " + item.isEnabled()
    );
    var regionId = item.getId();
    var isEnabled = item.isEnabled();
    if (isEnabled) {
      SkredvarselStorage.addSelectedRegion(regionId);
    } else {
      SkredvarselStorage.removeSelectedRegion(regionId);
    }

    WatchUi.requestUpdate();
  }

  //! Handle the back key being pressed
  public function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
