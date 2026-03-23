import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class EditMenuDelegate extends Ui.Menu2InputDelegate {
  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  public function onSelect(item as Ui.MenuItem) as Void {
    var editMenuItem = item as EditMenuItem;

    var regionId = editMenuItem.getId() as String;
    var isEnabled = editMenuItem.isEnabled();
    if (isEnabled) {
      var added = $.addSelectedRegion(regionId);
      if (!added) {
        editMenuItem.setEnabled(false);
        Ui.requestUpdate();
        Ui.pushView(
          new TextAreaView(
            Lang.format(
              $.getOrLoadResourceString(
                "You can select a maximum of $1$ areas.",
                :MaxSelectedAreas
              ),
              [$.getMaxSelectedRegions()]
            )
          ),
          new TextAreaViewDelegate(),
          Ui.SLIDE_BLINK
        );
      }
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
