import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class IntermediateBaseView extends Ui.View {
  private var _firstShow as Boolean;

  private var _textArea as Ui.TextArea?;

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

  public function onUpdate(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    if (_textArea == null) {
      _textArea = new Ui.TextArea({
        :text => _hitBackToExitText,
        :color => Gfx.COLOR_WHITE,
        :font => [Gfx.FONT_MEDIUM, Gfx.FONT_SMALL, Gfx.FONT_XTINY],
        :locX => Ui.LAYOUT_HALIGN_CENTER,
        :locY => Ui.LAYOUT_VALIGN_CENTER,
        :justification => Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER,
        :width => dc.getWidth() * 0.8,
        :height => dc.getHeight() * 0.8,
      });
    }
    _textArea.draw(dc);
  }

  public function onHide() {
    _hitBackToExitText = null;
    _textArea = null;
  }
}
