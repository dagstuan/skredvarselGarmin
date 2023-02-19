import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage;
using Toybox.Graphics as Gfx;

public class ForecastMenu extends Ui.CustomMenu {
  private const _editItemId = "edit";

  private var _skredvarselApi as SkredvarselApi;
  private var _skredvarselStorage as SkredvarselStorage;

  private var _existingRegionIds as Array<String> = new [0];

  public function initialize(
    skredvarselApi as SkredvarselApi,
    skredvarselStorage as SkredvarselStorage
  ) {
    CustomMenu.initialize(60, Gfx.COLOR_BLACK, {});
    _skredvarselApi = skredvarselApi;
    _skredvarselStorage = skredvarselStorage;
  }

  function onShow() {
    var regionIds = _skredvarselStorage.getSelectedRegionIds();

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
        addItem(new ForecastMenuItem(_skredvarselApi, regionId));
      }

      addItem(new ForecastMenuEditMenuItem(_editItemId));

      _existingRegionIds = regionIds;
    }
  }

  function drawTitle(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var iconResource = getIconResourceToDraw();
    var icon = Ui.loadResource(iconResource);
    var iconX = width / 2 - $.halfWidthDangerLevelIcon;
    dc.drawBitmap(iconX, 10, icon);

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
    var favoriteRegionId = _skredvarselStorage.getFavoriteRegionId();

    if (favoriteRegionId != null) {
      var forecastData =
        _skredvarselApi.getSimpleForecastForRegion(favoriteRegionId);

      if (forecastData != null) {
        var forecast = new SimpleAvalancheForecast(
          favoriteRegionId,
          forecastData[0]
        );

        var dangerLevelToday = forecast.getDangerLevelToday();

        return $.getIconResourceForDangerLevel(dangerLevelToday);
      }

      return $.Rez.Drawables.LauncherIcon;
    }

    return $.Rez.Drawables.LauncherIcon;
  }

  function deleteAllItems() {
    var deleteResult = deleteItem(0);
    while (deleteResult != null) {
      deleteResult = deleteItem(0);
    }
  }
}
