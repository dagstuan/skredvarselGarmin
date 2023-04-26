import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time;

typedef DetailedForecastFooterSettings as {
  :fetchedTime as Time.Moment,
  :locX as Numeric,
  :locY as Numeric,
  :width as Numeric,
  :height as Numeric,
  :isLoading as Boolean,
};

public class DetailedForecastFooter {
  private var _formattedFetchedTime as String;
  private var _locX as Numeric;
  private var _locY as Numeric;
  private var _width as Numeric;
  private var _height as Numeric;

  private var _font = Gfx.FONT_XTINY;
  private var _fontHeight as Number;

  private var _bufferedBitmapText as Gfx.BufferedBitmap?;
  private var _bufferedBitmapWidth as Numeric?;
  private var _bufferedBitmapHeight as Numeric?;

  private var _isLoading as Boolean;
  private var _loadingSpinner as AvalancheUi.LoadingSpinner?;

  public function initialize(settings as DetailedForecastFooterSettings) {
    _formattedFetchedTime = $.getFormattedTimestamp(settings[:fetchedTime]);

    _locX = settings[:locX];
    _locY = settings[:locY];
    _width = settings[:width];
    _height = settings[:height];
    _isLoading = settings[:isLoading];

    _fontHeight = Gfx.getFontHeight(_font);
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

    if (_bufferedBitmapText == null) {
      var updatedString = $.getOrLoadResourceString("Oppdatert", :Updated);
      var updatedShortString = $.getOrLoadResourceString(
        "Oppd.",
        :ShortUpdated
      );

      var text = updatedString + " " + _formattedFetchedTime;

      var screenWidthAtPoint = $.getScreenWidthAtPoint(
        $.getDeviceScreenWidth(),
        _locY + _height / 2
      );
      var textWidth = dc.getTextWidthInPixels(text, _font);
      if (textWidth > screenWidthAtPoint) {
        text = updatedShortString + " " + _formattedFetchedTime;
      }

      var textDimensions = dc.getTextDimensions(text, _font);

      _bufferedBitmapWidth = textDimensions[0];
      _bufferedBitmapHeight = textDimensions[1];

      _bufferedBitmapText = $.newBufferedBitmap({
        :width => _bufferedBitmapWidth,
        :height => _bufferedBitmapHeight,
      });
      var bufferedDc = _bufferedBitmapText.getDc();
      bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

      bufferedDc.drawText(
        _bufferedBitmapWidth / 2,
        _bufferedBitmapHeight / 2,
        _font,
        text,
        Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
      );
    }

    var textX0 = _locX + _width / 2 - _bufferedBitmapWidth / 2;
    var textY0 = _locY + _height / 2 - _fontHeight / 2;

    dc.drawBitmap(textX0, textY0, _bufferedBitmapText);
  }

  public function setIsLoading(isLoading as Boolean) {
    _isLoading = isLoading;
    if (_isLoading == false) {
      _loadingSpinner = null;
    }
  }
}
