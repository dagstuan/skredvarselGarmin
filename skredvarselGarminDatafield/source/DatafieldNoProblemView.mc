import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;

// Renders the no-problems layout:
//   [region name scrolling text]
//   [Faregrad N  icon]
//   [Ingen skredproblemer.]
// All three are vertically centered as a unit.
class DatafieldNoProblemView {
  private var _fieldWidth as Number;
  private var _fieldHeight as Number;

  private var _regionNameScrollingText as AvalancheUi.ScrollingText;
  private var _regionNameX0 as Numeric = 0;
  private var _noProblemsScrollingText as AvalancheUi.ScrollingText;

  private var _dangerLevel as Number;
  private var _headerFont as Gfx.FontType = Gfx.FONT_MEDIUM;
  private var _font as Gfx.FontType = Gfx.FONT_XTINY;

  private var _startY as Numeric = 0;
  private var _headerGapY as Numeric = 0;
  private var _noProblemsGapY as Numeric = 0;

  public function initialize(
    dc as Gfx.Dc,
    regionName as String,
    dangerLevel as Number,
    fieldWidth as Number,
    fieldHeight as Number
  ) {
    _fieldWidth = fieldWidth;
    _fieldHeight = fieldHeight;
    _dangerLevel = dangerLevel;

    var fontH = Gfx.getFontHeight(_font);
    var headerFontH = Gfx.getFontHeight(_headerFont);
    var icon =
      Ui.loadResource($.getIconResourceForDangerLevel(dangerLevel)) as
      Ui.BitmapResource;
    var headerLineH =
      headerFontH > icon.getHeight() ? headerFontH : icon.getHeight();

    _headerGapY = (_fieldHeight * 0.01).toNumber();
    _noProblemsGapY = _headerGapY;

    var totalH = fontH + _headerGapY + headerLineH + _noProblemsGapY + fontH;
    _startY = (_fieldHeight - totalH) / 2;

    // Calculate container width for region name, accounting for round screens
    var containerWidth = _fieldWidth;
    _regionNameX0 = 0;
    var screenWidth = $.getDeviceScreenWidth();
    var screenHeight = $.getDeviceScreenHeight();
    if (screenWidth == screenHeight && _fieldWidth >= screenWidth) {
      var textCenterY = _startY + fontH / 2.0;
      var r = screenWidth / 2.0;
      var dy = _fieldHeight / 2.0 - textCenterY;
      if (dy < r) {
        var chordWidth = (2.0 * Math.sqrt(r * r - dy * dy)).toNumber();
        var padding = (_fieldWidth * 0.04).toNumber();
        chordWidth -= padding * 2;
        if (chordWidth < _fieldWidth) {
          containerWidth = chordWidth;
          _regionNameX0 = (_fieldWidth - containerWidth) / 2;
        }
      }
    }

    _regionNameScrollingText = new AvalancheUi.ScrollingText({
      :dc => dc,
      :text => regionName,
      :containerWidth => containerWidth,
      :containerHeight => fontH,
      :scrollSpeed => 2,
      :font => _font,
      :color => Gfx.COLOR_WHITE,
      :backgroundColor => Gfx.COLOR_BLACK,
    });

    var noProblemsText = $.getOrLoadResourceString(
      "Ingen skredproblemer.",
      :NoProblems
    );
    _noProblemsScrollingText = new AvalancheUi.ScrollingText({
      :dc => dc,
      :text => noProblemsText,
      :containerWidth => _fieldWidth,
      :containerHeight => fontH,
      :scrollSpeed => 2,
      :font => _font,
      :color => Gfx.COLOR_WHITE,
      :backgroundColor => Gfx.COLOR_BLACK,
    });

    // Sync cycle lengths
    var regionCycle = _regionNameScrollingText.getCycleTicks();
    var noProblemsCycle = _noProblemsScrollingText.getCycleTicks();
    var maxCycle =
      regionCycle > noProblemsCycle ? regionCycle : noProblemsCycle;
    if (maxCycle > 0) {
      _regionNameScrollingText.setCycleTicks(maxCycle);
      _noProblemsScrollingText.setCycleTicks(maxCycle);
      AvalancheUi.resetScrollingTexts();
    }
  }

  public function onShow() as Void {
    _regionNameScrollingText.onShow();
    _noProblemsScrollingText.onShow();
  }

  public function draw(dc as Gfx.Dc) as Void {
    var fontH = Gfx.getFontHeight(_font);
    var headerFontH = Gfx.getFontHeight(_headerFont);

    var icon =
      Ui.loadResource($.getIconResourceForDangerLevel(_dangerLevel)) as
      Ui.BitmapResource;
    var iconW = icon.getWidth();
    var iconH = icon.getHeight();
    var gapX = (_fieldWidth * 0.02).toNumber();

    var dangerLevel = _dangerLevel;
    var dangerColor = $.colorize(dangerLevel);
    var levelText = $.getOrLoadResourceString("Faregrad", :Level);
    var headerText = Lang.format("$1$ $2$", [levelText, dangerLevel]);
    var textW = dc.getTextWidthInPixels(headerText, _headerFont);
    var totalW = textW + gapX + iconW;
    var headerX = (_fieldWidth - totalW) / 2;

    // Region name
    _regionNameScrollingText.draw(dc, _regionNameX0, _startY);

    // Danger level line — center both text and icon around the midpoint of headerLineH
    var headerLineH = headerFontH > iconH ? headerFontH : iconH;
    var dangerMidY = _startY + _headerGapY + fontH + headerLineH / 2;
    dc.setColor(dangerColor, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      headerX,
      dangerMidY,
      _headerFont,
      headerText,
      Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
    );
    dc.drawBitmap(headerX + textW + gapX, dangerMidY - iconH / 2, icon);

    // No problems text
    var noProblemsY =
      _startY + fontH + _headerGapY + headerLineH + _noProblemsGapY;
    _noProblemsScrollingText.draw(dc, 0, noProblemsY);
  }
}
