import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class WidgetViewDelegate extends Ui.BehaviorDelegate {
  private var _mainView as Ui.View;
  private var _mainViewDelegate as Ui.Menu2InputDelegate;

  public function initialize(
    mainView as Ui.View,
    mainViewDelegate as Ui.Menu2InputDelegate
  ) {
    BehaviorDelegate.initialize();

    _mainView = mainView;
    _mainViewDelegate = mainViewDelegate;
  }

  public function onSelect() as Boolean {
    Ui.pushView(_mainView, _mainViewDelegate, Ui.SLIDE_LEFT);
    return true;
  }

  public function onBack() as Boolean {
    Ui.popView(WatchUi.SLIDE_DOWN);
    return true;
  }
}
