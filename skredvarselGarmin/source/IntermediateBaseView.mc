import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class IntermediateBaseView extends Ui.View {
  private var _firstShow;

  private var _mainView as Ui.View;
  private var _mainViewDelegate as Ui.Menu2InputDelegate;

  private var _width as Number?;
  private var _height as Number?;

  public function initialize(
    mainView as Ui.View,
    mainViewDelegate as Ui.Menu2InputDelegate
  ) {
    View.initialize();

    _firstShow = true;
    _mainView = mainView;
    _mainViewDelegate = mainViewDelegate;
  }

  public function onShow() {
    if (_firstShow) {
      Ui.pushView(_mainView, _mainViewDelegate, Ui.SLIDE_IMMEDIATE);
      _firstShow = false;
    }
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  public function onUpdate(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    var hitBackToExitText = Ui.loadResource($.Rez.Strings.HitBackToExit);

    dc.drawText(
      _width / 2,
      _height / 2,
      Gfx.FONT_SMALL,
      hitBackToExitText,
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    );
  }
}
