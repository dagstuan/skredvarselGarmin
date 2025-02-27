import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

public class ForecastMenu extends Ui.CustomMenu {
  private const _marginLeftRightPercent = 0.13;

  private var _existingRegionIds as Array<String> = new [0];

  private var _titleBitmap as Gfx.BufferedBitmap?;
  private var _footerTextBitmap as Gfx.BufferedBitmap?;

  private var _font = Gfx.FONT_XTINY;
  private var _fontHeight = Gfx.getFontHeight(_font);

  private var _screenHeight = $.getDeviceScreenHeight();

  public function initialize() {
    var menuElementsHeight = 60;
    if (_screenHeight > 260) {
      menuElementsHeight += ((_screenHeight - 260) * 0.2).toNumber();
    }

    CustomMenu.initialize(menuElementsHeight, Gfx.COLOR_BLACK, {});
  }

  function onShow() {
    var selectedRegionIds = $.getSelectedRegionIds();
    var numRegions = selectedRegionIds.size();

    if (numRegions == 0) {
      _existingRegionIds = selectedRegionIds;
      deleteAllItems();

      var useLocation = $.getUseLocation();
      if (useLocation) {
        addItem(
          new ForecastMenuItem({ :menu => self, :isLocationForecast => true })
        );
      }

      addItem(new ForecastMenuEditMenuItem("edit"));
      redrawTitleAndFooter();
      return;
    }

    var regionsChanged = false;
    if (numRegions != _existingRegionIds.size()) {
      regionsChanged = true;
    } else {
      for (var i = 0; i < selectedRegionIds.size(); i++) {
        if (!selectedRegionIds[i].equals(_existingRegionIds[i])) {
          regionsChanged = true;
          break;
        }
      }
    }

    if (regionsChanged) {
      deleteAllItems();

      var useLocation = $.getUseLocation();
      if (useLocation) {
        addItem(
          new ForecastMenuItem({ :menu => self, :isLocationForecast => true })
        );
      }

      for (var i = 0; i < selectedRegionIds.size(); i++) {
        addItem(
          new ForecastMenuItem({
            :menu => self,
            :regionId => selectedRegionIds[i],
          })
        );
      }

      addItem(new ForecastMenuEditMenuItem("edit"));
      setFocus(0);
      redrawTitleAndFooter();
    }

    _existingRegionIds = selectedRegionIds;
  }

  function drawTitle(dc as Gfx.Dc) {
    if (_titleBitmap == null) {
      var width = dc.getWidth();
      var height = dc.getHeight();

      _titleBitmap = $.newBufferedBitmap({
        :width => width,
        :height => height,
      });
      var bufferedDc = _titleBitmap.getDc();

      bufferedDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      bufferedDc.clear();

      var icon = Ui.loadResource($.getIconResourceForForecastMenu());

      var iconX = width / 2 - $.getHalfWidthDangerLevelIcon();
      bufferedDc.drawBitmap(iconX, 10, icon);

      var text = $.getOrLoadResourceString("Skredvarsel", :AppName);
      bufferedDc.drawText(
        width / 2,
        height / 2 + 15,
        _font,
        text,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );

      bufferedDc.setPenWidth(1);
      bufferedDc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

      var offsetFromBottom = height * 0.15;
      var marginLeftRight = width * _marginLeftRightPercent;

      bufferedDc.drawLine(
        marginLeftRight,
        height - offsetFromBottom,
        width - marginLeftRight,
        height - offsetFromBottom
      );
    }

    dc.drawBitmap(0, 0, _titleBitmap);
  }

  public function drawFooter(dc as Gfx.Dc) {
    var width = dc.getWidth();
    if (_footerTextBitmap == null && _existingRegionIds.size() > 0) {
      var lastUpdatedTime = getLastUpdatedTime();

      if (lastUpdatedTime != null) {
        _footerTextBitmap = $.newBufferedBitmap({
          :width => width,
          :height => _fontHeight,
        });
        var bufferedDc = _footerTextBitmap.getDc();

        bufferedDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var formattedTimestamp = $.getFormattedTimestamp(
          new Time.Moment(lastUpdatedTime)
        );

        var text = Lang.format("$1$ $2$", [
          $.getOrLoadResourceString("Oppdatert", :Updated),
          formattedTimestamp,
        ]);

        bufferedDc.drawText(
          width / 2,
          _fontHeight / 2,
          _font,
          text,
          Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
      }
    }

    if (_footerTextBitmap != null) {
      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.clear();
      dc.setPenWidth(1);

      var offsetFromTop = 15;
      var marginLeftRight = width * _marginLeftRightPercent;

      dc.drawLine(
        marginLeftRight,
        offsetFromTop,
        width - marginLeftRight,
        offsetFromTop
      );

      var textOffsetFromTop = 35;
      if (_screenHeight > 260) {
        textOffsetFromTop += ((_screenHeight - 260) * 0.1).toNumber();
      }

      dc.drawBitmap(0, textOffsetFromTop - _fontHeight / 2, _footerTextBitmap);
    }
  }

  private function getLastUpdatedTime() as Number? {
    var updatedTimes = new [0];
    for (var i = 0; i < _existingRegionIds.size(); i++) {
      var data = $.getSimpleForecastForRegion(_existingRegionIds[i]);
      if (data != null) {
        updatedTimes.add(data[1]);
      }
    }

    return updatedTimes.size() > 0 ? $.minValue(updatedTimes) : null;
  }

  function deleteAllItems() {
    var deleteResult = deleteItem(0);
    while (deleteResult != null) {
      deleteResult = deleteItem(0);
    }
  }

  public function redrawTitleAndFooter() {
    _titleBitmap = null;
    _footerTextBitmap = null;

    Ui.requestUpdate();
  }
}

function getIconResourceForForecastMenu() as ResourceId {
  var favoriteRegionId = $.getFavoriteRegionId();

  if (favoriteRegionId != null) {
    var forecast = $.getSimpleForecastForRegion(favoriteRegionId);

    if (forecast != null) {
      var dangerLevelToday = $.getDangerLevelToday(forecast[0]);

      return $.getIconResourceForDangerLevel(dangerLevelToday);
    }
  }

  return $.Rez.Drawables.Level2;
}
