import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class WidgetViewDelegate extends Ui.BehaviorDelegate {
  public function initialize() {
    BehaviorDelegate.initialize();
  }

  public function onSelect() as Boolean {
    Ui.pushView(new ForecastMenu(), new ForecastMenuDelegate(), Ui.SLIDE_LEFT);
    return true;
  }

  public function onBack() as Boolean {
    Ui.popView(WatchUi.SLIDE_DOWN);
    return true;
  }
}
