using Toybox.WatchUi as Ui;

class SettingsMenu extends Ui.Menu2 {
  function initialize() {
    Menu2.initialize(null);
    Menu2.setTitle("Settings");
    Menu2.addItem(
      new Ui.ToggleMenuItem(
        "Show Seconds When Possible",
        null,
        "sec",
        false,
        null
      )
    );
    //other things
  }
}
