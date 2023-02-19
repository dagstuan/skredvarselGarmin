import Toybox.Lang;

using Toybox.WatchUi as Ui;

class ProgressDelegate extends Ui.BehaviorDelegate {
  public function initialize() {
    BehaviorDelegate.initialize();
  }

  public function onBack() as Boolean {
    Ui.popView(Ui.SLIDE_RIGHT);
    return true;
  }
}
