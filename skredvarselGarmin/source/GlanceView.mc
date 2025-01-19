using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using AvalancheUi;

(:glance)
class GlanceView extends Ui.GlanceView {
  private var _hasSubscription as Lang.Boolean?;
  private var _favoriteRegionId as Lang.String?;

  private var _forecastData as SimpleForecastData?;
  private var _dataAge as Lang.Number?;

  (:typecheck(false)) // Will be unused for watches that don't use buffered glances.
  private var _bufferedBitmap as Gfx.BufferedBitmap?;

  private var _width as Lang.Number?;
  private var _height as Lang.Number?;

  private var _appNameText as Ui.Resource?;

  private var _useLocation as Lang.Boolean = false;

  function initialize() {
    GlanceView.initialize();
  }

  function onShow() {
    _hasSubscription = $.getHasSubscription();
    _favoriteRegionId = $.getFavoriteRegionId();
    _useLocation = $.getUseLocation();
    _appNameText = $.getOrLoadResourceString("Skredvarsel", :AppName);
  }

  function onLayout(dc as Gfx.Dc) {
    _width = dc.getWidth();
    _height = dc.getHeight();
  }

  function onUpdate(dc as Gfx.Dc) {
    if (
      _hasSubscription &&
      (_favoriteRegionId != null || _useLocation) &&
      _forecastData == null
    ) {
      setForecastDataFromStorage();
    }

    if (
      _hasSubscription == false ||
      !(_favoriteRegionId != null || _useLocation) ||
      _forecastData == null ||
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

    if (self has :drawTimelineBuffered) {
      drawTimelineBuffered(dc);
    } else {
      drawTimeline(dc);
    }
  }

  (:useBufferedBitmapOnGlance)
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
    (
      new AvalancheUi.ForecastTimeline({
        :locX => 0,
        :locY => 0,
        :width => _width,
        :height => _height,
        :regionName => $.getRegionName(
          _useLocation
            ? (_forecastData as LocationAvalancheForecast)["regionId"]
            : _favoriteRegionId
        ),
        :forecast => _useLocation
          ? (_forecastData as LocationAvalancheForecast)["warnings"]
          : _forecastData,
        :isLocationForecast => _useLocation,
      })
    ).draw(dc);
  }

  function onHide() {
    _appNameText = null;
    _bufferedBitmap = null;
  }

  private function setForecastDataFromStorage() as Void {
    var data = _useLocation
      ? $.getSimpleForecastForLocation()
      : $.getSimpleForecastForRegion(_favoriteRegionId);

    if (data != null) {
      _bufferedBitmap = null;
      _forecastData = data[0];
      _dataAge = $.getStorageDataAge(data);
    }
  }
}
