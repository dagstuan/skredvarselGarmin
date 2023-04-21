import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

using AvalancheUi;

(:glance)
function getMemoryConstrainedDevices() {
  return [
    "006-B3258-00", // Descent Mk 2
    "006-B3702-00", // Descent Mk 2
    "006-B3542-00", // Descent Mk 2s
    "006-B3930-00", // Descent Mk 2s
    "006-B3290-00", // F6 Pro
    "006-B3515-00", // F6 Pro
    "006-B3782-00", // F6 Pro
    "006-B3767-00", // F6 Pro
    "006-B3771-00", // F6 Pro
    "006-B3288-00", // F6S Pro
    "006-B3513-00", // F6S Pro
    "006-B3765-00", // F6S Pro
    "006-B3769-00", // F6S Pro
    "006-B3291-00", // F6X Pro
    "006-B3516-00", // F6X Pro
    "006-B3783-00", // F6X Pro
    "006-B3589-00", // FR745
    "006-B3794-00", // FR745
    "006-B3113-00", // FR945
    "006-B3441-00", // FR945
    "006-B3652-00", // FR945 LTE
    "006-B3077-00", // FR245 Music
    "006-B3321-00", // FR245 Music
    "006-B3913-00", // FR245 Music
    "006-B3624-00", // Marq Adventurer
    "006-B3648-00", // Marq Adventurer
    "006-B3251-00", // Marq Athlete
    "006-B3451-00", // Marq Athlete
    "006-B3247-00", // Marq Aviator
    "006-B3421-00", // Marq Aviator
    "006-B3248-00", // Marq Captain
    "006-B3448-00", // Marq Captain
    "006-B3249-00", // Marq Commander
    "006-B3449-00", // Marq Commander
    "006-B3246-00", // Marq Driver
    "006-B3420-00", // Marq Driver
    "006-B3250-00", // Marq Expedition
    "006-B3450-00", // Marq Expedition
    "006-B3739-00", // Marq Golfer
    "006-B3850-00", // Marq Golfer
  ];
}

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _hasSubscription as Boolean?;
  private var _favoriteRegionId as String?;

  private var _forecast as SimpleAvalancheForecast?;
  private var _dataAge as Number?;

  private var _bufferedBitmap as Gfx.BufferedBitmap?;
  private var _useBufferedBitmap as Boolean = true;

  private var _width as Number?;
  private var _height as Number?;

  private var _appNameText as Ui.Resource?;

  function initialize() {
    GlanceView.initialize();

    var deviceSettings = System.getDeviceSettings();
    var partNumber = deviceSettings.partNumber;

    if (arrayContainsString(getMemoryConstrainedDevices(), partNumber)) {
      _useBufferedBitmap = false;
    }
  }

  function onShow() {
    _hasSubscription = $.getHasSubscription();
    _favoriteRegionId = $.getFavoriteRegionId();
    _appNameText = $.getOrLoadResourceString("Skredvarsel", :AppName);
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  function onUpdate(dc as Gfx.Dc) {
    if (_hasSubscription && _favoriteRegionId != null && _forecast == null) {
      setForecastDataFromStorage();
    }

    if (
      _hasSubscription == false ||
      _favoriteRegionId == null ||
      _forecast == null ||
      _dataAge > $.TIME_TO_SHOW_LOADING
    ) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        0,
        _height / 2,
        Gfx.FONT_GLANCE,
        _appNameText,
        Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
      );
      return;
    }

    if (_useBufferedBitmap) {
      drawTimelineBuffered(dc);
    } else {
      drawTimeline(dc);
    }
  }

  function drawTimelineBuffered(dc as Gfx.Dc) {
    if (_bufferedBitmap == null) {
      _bufferedBitmap = $.newBufferedBitmap({
        :width => _width,
        :height => _height,
      });
      var bufferedDc = _bufferedBitmap.getDc();

      drawTimeline(bufferedDc);
    }

    dc.drawBitmap(0, 0, _bufferedBitmap);
  }

  function drawTimeline(dc as Gfx.Dc) {
    var regionName = $.getRegionName(_favoriteRegionId);

    var forecastTimeline = new AvalancheUi.ForecastTimeline({
      :locX => 0,
      :locY => 0,
      :width => _width,
      :height => _height,
      :regionName => regionName,
      :forecast => _forecast,
    });

    forecastTimeline.draw(dc);
  }

  function onHide() {
    _appNameText = null;
    _bufferedBitmap = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = $.getSimpleForecastForRegion(_favoriteRegionId);

    if (data != null) {
      _bufferedBitmap = null;
      _forecast = data[0];
      _dataAge = $.getStorageDataAge(data);
    }
  }
}
