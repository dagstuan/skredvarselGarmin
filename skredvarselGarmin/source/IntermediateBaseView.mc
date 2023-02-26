import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class IntermediateBaseView extends Ui.View {
  private var _firstShow;

  private var _width as Number?;
  private var _height as Number?;

  private var _hitBackToExitText as Ui.Resource?;

  public function initialize() {
    View.initialize();

    _firstShow = true;
  }

  public function onShow() {
    if (_firstShow) {
      Ui.pushView(
        new ForecastMenu(),
        new ForecastMenuDelegate(),
        Ui.SLIDE_IMMEDIATE
      );
      _firstShow = false;
    }

    _hitBackToExitText = Ui.loadResource($.Rez.Strings.HitBackToExit);
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  public function onUpdate(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    dc.drawText(
      _width / 2,
      _height / 2,
      Gfx.FONT_SMALL,
      _hitBackToExitText,
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    );
  }

  public function onHide() {
    _hitBackToExitText = null;
  }
}
