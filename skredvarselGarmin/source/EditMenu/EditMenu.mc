import Toybox.Lang;

using Toybox.WatchUi as Ui;

public class EditMenu extends Ui.Menu2 {
  public function initialize() {
    Menu2.initialize({ :title => $.Rez.Strings.PickRegions });

    var selectedRegionIds = $.getSelectedRegionIds() as Array<String>;

    var regions = $.getSortedRegionIds();
    for (var i = 0; i < regions.size(); i++) {
      var regionId = regions[i];
      var regionName = $.getRegionName(regionId);

      var isSelected = arrayContainsString(selectedRegionIds, regionId);
      addItem(new EditMenuItem(regionName, regionId, isSelected));
    }
  }
}
