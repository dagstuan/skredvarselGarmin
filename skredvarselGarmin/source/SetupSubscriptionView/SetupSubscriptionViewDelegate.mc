import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class SetupSubscriptionViewDelegate extends Ui.BehaviorDelegate {
  public function initialize() {
    BehaviorDelegate.initialize();
  }

  public function onSelect() as Boolean {
    return true;
  }
}
