import Toybox.Lang;

using Toybox.WatchUi as Ui;

class SettingsMenuDelegate extends Ui.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var id = item.getId();
  }

  function onBack() {
    WatchUi.popView(Ui.SLIDE_IMMEDIATE);
  }
}
