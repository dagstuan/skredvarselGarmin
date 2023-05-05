import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.WatchUi as Ui;

typedef DetailedForecastFooterSettings as {
  :publishedTime as String?,
  :locX as Numeric,
  :locY as Numeric,
  :width as Numeric,
  :height as Numeric,
  :isLoading as Boolean,
};

public class DetailedForecastFooter {
  private var _publishedTime as String?;
  private var _locX as Numeric;
  private var _locY as Numeric;
  private var _width as Numeric;
  private var _height as Numeric;

  private var _font = Gfx.FONT_XTINY;
  private var _fontHeight as Number;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;
  private var _bufferedBitmapWidth as Numeric?;
  private var _bufferedBitmapHeight as Numeric?;

  private var _isLoading as Boolean;
  private var _loadingSpinner as AvalancheUi.LoadingSpinner?;

  private var _deviceScreenWidth as Number;

  public function initialize(settings as DetailedForecastFooterSettings) {
    _publishedTime = settings[:publishedTime];

    _locX = settings[:locX];
    _locY = settings[:locY];
    _width = settings[:width];
    _height = settings[:height];
    _isLoading = settings[:isLoading];

    _fontHeight = Gfx.getFontHeight(_font);

    _deviceScreenWidth = $.getDeviceScreenWidth();
  }

  public function onTick() {
    if (_loadingSpinner != null) {
      _loadingSpinner.onTick();
    }
  }

  public function draw(dc as Gfx.Dc) {
    if (_isLoading) {
      if (_loadingSpinner == null) {
        _loadingSpinner = new AvalancheUi.LoadingSpinner({
          :locX => _locX + _width / 2.0,
          :locY => _locY + _height / 2.0,
          :radius => _fontHeight / 2.0,
        });
      }

      _loadingSpinner.draw(dc);
      return;
    }

    if (_bufferedBitmap == null && _publishedTime != null) {
      var updatedIcon =
        Ui.loadResource($.Rez.Drawables.UpdatedIcon) as Ui.BitmapResource;
      var iconWidth = updatedIcon.getWidth();
      var iconHeight = updatedIcon.getHeight();
      var gap = 5;

      var publishedMoment = $.parseDate(_publishedTime);
      var dateText = $.getHumanReadableDateText(publishedMoment);
      var timestamp = $.getFormattedTimestamp(publishedMoment);
      var text = Lang.format("$1$ $2$", [dateText, timestamp]);

      var textDimensions = dc.getTextDimensions(text, _font);

      _bufferedBitmapWidth = iconWidth + gap + textDimensions[0];
      _bufferedBitmapHeight =
        textDimensions[1] > iconHeight ? textDimensions[1] : iconHeight;

      _bufferedBitmap = $.newBufferedBitmap({
        :width => _bufferedBitmapWidth,
        :height => _bufferedBitmapHeight,
      });
      var bufferedDc = _bufferedBitmap.getDc();
      bufferedDc.setAntiAlias(true);
      bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

      bufferedDc.drawBitmap(
        0,
        _bufferedBitmapHeight / 2.0 - iconHeight / 2.0,
        updatedIcon
      );

      bufferedDc.drawText(
        iconWidth + gap,
        _bufferedBitmapHeight / 2.0 - _fontHeight / 2.0,
        _font,
        text,
        Gfx.TEXT_JUSTIFY_LEFT
      );
    }

    if (_bufferedBitmap != null) {
      var textX0 = _locX + _width / 2.0 - _bufferedBitmapWidth / 2.0;
      var textY0 =
        _deviceScreenWidth > 240 ? _locY + _bufferedBitmapHeight / 2.0 : _locY;

      dc.drawBitmap(textX0, textY0, _bufferedBitmap);
    }
  }

  public function onUpdate(isLoading as Boolean, publishedTime as String?) {
    _isLoading = isLoading;
    if (_isLoading == false) {
      _loadingSpinner = null;
    }
    _publishedTime = publishedTime;
    _bufferedBitmap = null;
  }
}
