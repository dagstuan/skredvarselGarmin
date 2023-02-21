import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class EditMenu extends Ui.Menu2 {
  public function initialize() {
    Menu2.initialize({ :title => $.Rez.Strings.PickRegions });

    var selectedRegionIds = $.getSelectedRegionIds() as Array<String>;

    var regions = $.getRegions();
    var regionIds = regions.keys();
    for (var i = 0; i < regionIds.size(); i++) {
      var regionId = regionIds[i] as String;
      var regionName = regions[regionId];

      var isSelected = arrayContainsString(selectedRegionIds, regionId);
      addItem(new EditMenuItem(regionName, regionId, isSelected));
    }
  }
}
