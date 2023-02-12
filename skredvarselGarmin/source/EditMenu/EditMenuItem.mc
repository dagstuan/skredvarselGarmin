import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class EditMenuItem extends Ui.ToggleMenuItem {
  public function initialize(label as String, identifier, enabled as Boolean) {
    ToggleMenuItem.initialize(label, null, identifier, enabled, {
      :alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT,
    });
  }
}
