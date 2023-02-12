import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application.Storage;
using Toybox.Graphics as Gfx;

public class ForecastMenu extends WatchUi.CustomMenu {
  public static const MarginRight = 25;

  private const _editItemId = "edit";

  private var _skredvarselApi as SkredvarselApi;
  private var _logo as BitmapResource?;

  private var _existingRegionItems as Array<String> = new [0];

  public function initialize(skredvarselApi) {
    CustomMenu.initialize(60, Graphics.COLOR_BLACK, {});
    _skredvarselApi = skredvarselApi;
  }

  function onShow() {
    _logo =
      WatchUi.loadResource($.Rez.Drawables.LauncherIcon) as BitmapResource;

    var regionIds = SkredvarselStorage.getSelectedRegionIds();

    var editElementIndex = findItemById(_editItemId);
    if (editElementIndex > 0) {
      deleteItem(editElementIndex);
    }

    // Remove items that should no longer exist
    var numExistingItems = _existingRegionItems.size();
    if (numExistingItems > 0) {
      for (var i = 0; i < numExistingItems; i++) {
        var existingRegionId = _existingRegionItems[i];
        if (!arrayContainsString(regionIds, existingRegionId)) {
          var index = findItemById(existingRegionId);
          if (index > 0) {
            deleteItem(index);
          }
        }
      }
    }

    // Add items that are new.
    for (var i = 0; i < regionIds.size(); i++) {
      var regionId = regionIds[i];
      if (!arrayContainsString(_existingRegionItems, regionId)) {
        addItem(new ForecastMenuItem(_skredvarselApi, regionId));
      }
    }

    _existingRegionItems = regionIds;

    addItem(new ForecastMenuEditMenuItem(_editItemId));
  }

  function drawTitle(dc as Gfx.Dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    if (_logo != null) {
      var offsetX = _logo.getWidth() / 2;
      var logoX = width / 2 - offsetX;

      dc.drawBitmap(logoX, 10, _logo);
    }

    dc.drawText(
      width / 2,
      height / 2 + 15,
      Graphics.FONT_XTINY,
      "Skredvarsel",
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
}
