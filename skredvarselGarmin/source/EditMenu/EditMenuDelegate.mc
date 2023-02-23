using Toybox.WatchUi as Ui;

public class EditMenuDelegate extends Ui.Menu2InputDelegate {
  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  //! Handle an item being selected
  //! @param item The selected menu item
  public function onSelect(item as EditMenuItem) as Void {
    var regionId = item.getId();
    var isEnabled = item.isEnabled();
    if (isEnabled) {
      $.addSelectedRegion(regionId);
    } else {
      $.removeSelectedRegion(regionId);
    }
  }

  function onReloadedRegion() as Void {
    WatchUi.requestUpdate();
  }

  //! Handle the back key being pressed
  public function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
