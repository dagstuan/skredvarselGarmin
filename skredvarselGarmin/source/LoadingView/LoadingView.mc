import Toybox.Lang;

using Toybox.WatchUi as Ui;

class LoadingView extends Ui.ProgressBar {
  public function initialize() {
    var loadingText = Ui.loadResource($.Rez.Strings.Loading);

    ProgressBar.initialize(loadingText, null);
  }
}
