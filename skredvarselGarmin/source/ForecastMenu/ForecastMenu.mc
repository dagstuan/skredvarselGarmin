import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;

public class ForecastMenu extends Ui.CustomMenu {
  private const _editItemId = "edit";

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
    var regionIds = $.getSelectedRegionIds();
    var numRegions = regionIds.size();

    if (numRegions == 0) {
      _existingRegionIds = regionIds;
      deleteAllItems();
      addItem(new ForecastMenuEditMenuItem(_editItemId));
      redrawTitleAndFooter();
      return;
    }

    var regionsChanged = false;
    if (numRegions != _existingRegionIds.size()) {
      regionsChanged = true;
    } else {
      for (var i = 0; i < regionIds.size(); i++) {
        if (!regionIds[i].equals(_existingRegionIds[i])) {
          regionsChanged = true;
          break;
        }
      }
    }

    if (regionsChanged) {
      deleteAllItems();
      for (var i = 0; i < regionIds.size(); i++) {
        addItem(new ForecastMenuItem(self, regionIds[i]));
      }

      addItem(new ForecastMenuEditMenuItem(_editItemId));
      setFocus(0);
      redrawTitleAndFooter();
    }

    _existingRegionIds = regionIds;
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

      var iconResource = getIconResourceToDraw();
      var icon = Ui.loadResource(iconResource);

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

      var offsetFromBottom = 15;
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

        var updatedString = $.getOrLoadResourceString("Oppdatert", :Updated);
        var text = updatedString + " " + formattedTimestamp;

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

  private function getIconResourceToDraw() as Symbol {
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

  private function getLastUpdatedTime() as Number? {
    if (_existingRegionIds.size() == 0) {
      return null;
    }

    var updatedTimes = new [0];
    for (var i = 0; i < _existingRegionIds.size(); i++) {
      var data = $.getSimpleForecastForRegion(_existingRegionIds[i]);
      if (data != null) {
        updatedTimes.add(data[1]);
      }
    }

    if (updatedTimes.size() == 0) {
      return null;
    }

    return minValue(updatedTimes);
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
