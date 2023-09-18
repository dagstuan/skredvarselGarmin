using Toybox.WatchUi as Ui;

public class EditMenuDelegate extends Ui.Menu2InputDelegate {
  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  public function onSelect(item as Ui.MenuItem) as Void {
    var editMenuItem = item as EditMenuItem;

    var regionId = editMenuItem.getId();
    var isEnabled = editMenuItem.isEnabled();
    if (isEnabled) {
      $.addSelectedRegion(regionId);
    } else {
      $.removeSelectedRegion(regionId);
    }
  }

  function onReloadedRegion() as Void {
    WatchUi.requestUpdate();
  }

  public function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
