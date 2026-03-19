import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Math;
using AvalancheUi;

typedef DetailedForecastHeaderSettings as {
  :dc as Gfx.Dc,
  :regionName as String,
  :validityDate as String,
  :locX as Numeric,
  :locY as Numeric,
  :width as Numeric,
  :height as Numeric,
};

public class DetailedForecastHeader {
  private var _locX as Numeric;
  private var _locY as Numeric;
  private var _width as Numeric;
  private var _height as Numeric;

  private var _font = Gfx.FONT_XTINY;
  private var _fontHeight as Number = Gfx.getFontHeight(_font);

  private var _deviceScreenWidth as Numeric = $.getDeviceScreenWidth();

  private var _dateBitmap as Gfx.BufferedBitmap?;
  private var _dateBitmapWidth as Numeric = 0;

  private var _regionNameText as AvalancheUi.ScrollingText?;
  private var _regionNameX0 as Numeric = 0;

  public function initialize(settings as DetailedForecastHeaderSettings) {
    _locX = settings[:locX];
    _locY = settings[:locY];
    _width = settings[:width];
    _height = settings[:height];

    setupBufferedBitmaps(settings[:dc], settings[:validityDate], settings[:regionName]);
  }

  public function onShow() as Void {
    if (_regionNameText != null) {
      _regionNameText.onShow();
    }
  }

  public function onHide() as Void {
    if (_regionNameText != null) {
      _regionNameText.onHide();
    }
  }

  public function onTick() as Void {
    if (_regionNameText != null) {
      _regionNameText.onTick();
    }
  }

  private function setupBufferedBitmaps(dc as Gfx.Dc, validityDate as String, regionName as String) {
    _dateBitmapWidth = dc.getTextWidthInPixels(validityDate, _font);

    _dateBitmap = $.newBufferedBitmap({
      :width => _dateBitmapWidth,
      :height => _fontHeight,
    });
    var bufferedDc = _dateBitmap.getDc();
    bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    bufferedDc.drawText(0, 0, _font, validityDate, Gfx.TEXT_JUSTIFY_LEFT);

    if (_deviceScreenWidth > 240) {
      var totalHeight = _fontHeight * 2;
      var regionNameY = _locY + (_height - totalHeight) / 2 + _fontHeight;

      // On a round screen, calculate the chord width at the region name's Y position.
      var r = _deviceScreenWidth / 2.0;
      var dy = r - regionNameY;
      var regionNameWidth = 2.0 * Math.sqrt(r * r - dy * dy);

      _regionNameX0 = (_width - regionNameWidth) / 2.0;

      _regionNameText = new AvalancheUi.ScrollingText({
        :dc => dc,
        :text => regionName,
        :containerWidth => regionNameWidth,
        :containerHeight => _fontHeight,
        :font => _font,
        :scrollDirection => AvalancheUi.SCROLL_DIRECTION_HORIZONTAL,
      });
    }
  }

  public function draw(dc as Gfx.Dc) {
    if (_deviceScreenWidth > 240) {
      var totalHeight = _fontHeight * 2;
      var topY = _locY + (_height - totalHeight) / 2;

      dc.drawBitmap(_locX + _width / 2 - _dateBitmapWidth / 2, topY, _dateBitmap);

      if (_regionNameText != null) {
        _regionNameText.draw(dc, _regionNameX0, topY + _fontHeight);
      }
    } else {
      dc.drawBitmap(
        _locX + _width / 2 - _dateBitmapWidth / 2,
        _locY + _height / 2 - _fontHeight / 2,
        _dateBitmap
      );
    }
  }
}
