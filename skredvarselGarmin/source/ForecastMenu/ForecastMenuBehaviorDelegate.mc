import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

public class ForecastMenuBehaviorDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() as Boolean {
    System.println("menu!");
    return true;
  }
}
