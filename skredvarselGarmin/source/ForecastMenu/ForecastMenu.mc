import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage;
using Toybox.Graphics as Gfx;
using Toybox.Math;

public class ForecastMenu extends Ui.CustomMenu {
  private const _editItemId = "edit";

  private var _existingRegionIds as Array<String> = new [0];

  private var _icon as Ui.Resource?;

  public function initialize() {
    var screenHeight = $.getDeviceScreenHeight();

    var menuElementsHeight = 60;
    if (screenHeight > 260) {
      menuElementsHeight += ((screenHeight - 260) * 0.2).toNumber();
    }

    CustomMenu.initialize(menuElementsHeight, Gfx.COLOR_BLACK, {});
  }

  function onShow() {
    var regionIds = $.getSelectedRegionIds();

    var regionsChanged = false;
    if (regionIds.size() != _existingRegionIds) {
      regionsChanged = true;
    } else {
      for (var i = 0; i < regionIds.size(); i++) {
        if (!regionIds[i].equals(_existingRegionIds[i])) {
          regionsChanged = true;
        }
      }
    }

    if (regionsChanged) {
      deleteAllItems();
      for (var i = 0; i < regionIds.size(); i++) {
        var regionId = regionIds[i];
        addItem(new ForecastMenuItem(regionId));
      }

      addItem(new ForecastMenuEditMenuItem(_editItemId));

      setFocus(0);

      _existingRegionIds = regionIds;
    }
  }

  function drawTitle(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    if (_icon == null) {
      var iconResource = getIconResourceToDraw();
      _icon = Ui.loadResource(iconResource);
    }

    var iconX = width / 2 - $.halfWidthDangerLevelIcon;
    dc.drawBitmap(iconX, 10, _icon);

    var text = Ui.loadResource($.Rez.Strings.AppName);
    dc.drawText(
      width / 2,
      height / 2 + 15,
      Graphics.FONT_XTINY,
      text,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.setPenWidth(1);

    var offsetFromBottom = 15;
    var marginLeftRight = 35;

    dc.drawLine(
      marginLeftRight,
      height - offsetFromBottom,
      width - marginLeftRight,
      height - offsetFromBottom
    );
  }

  private function getIconResourceToDraw() as Symbol {
    var favoriteRegionId = $.getFavoriteRegionId();

    if (favoriteRegionId != null) {
      var forecast = $.getSimpleForecastForRegion(favoriteRegionId);

      if (forecast != null) {
        var dangerLevelToday = $.getDangerLevelToday(forecast[0]);

        return $.getIconResourceForDangerLevel(dangerLevelToday);
      }

      return $.Rez.Drawables.Level2;
    }

    return $.Rez.Drawables.Level2;
  }

  function deleteAllItems() {
    var deleteResult = deleteItem(0);
    while (deleteResult != null) {
      deleteResult = deleteItem(0);
    }
  }
}
