import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class TextAreaView extends Ui.View {
  private var _textArea as Ui.TextArea?;
  private var _text as String;

  function initialize(text as String) {
    View.initialize();

    _text = text;
  }

  function onLayout(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    _textArea = new Ui.TextArea({
      :text => _text,
      :color => Gfx.COLOR_WHITE,
      :font => [Gfx.FONT_SMALL, Gfx.FONT_XTINY],
      :locX => Ui.LAYOUT_HALIGN_CENTER,
      :locY => Ui.LAYOUT_VALIGN_CENTER,
      :justification => Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER,
      :width => width * 0.8,
      :height => height * 0.8,
    });
  }

  function onUpdate(dc as Gfx.Dc) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.clear();
    _textArea.draw(dc);
  }
}
