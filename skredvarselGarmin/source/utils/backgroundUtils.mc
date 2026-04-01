import Toybox.Lang;

using Toybox.Application.Properties;

(:background)
var enableBackgroundFetching as Lang.Boolean?;

(:background)
function getEnableBackgroundFetching() as Lang.Boolean {
  if ($.enableBackgroundFetching == null) {
    var enabled =
      Properties.getValue("enableBackgroundFetching") as Lang.Boolean?;
    $.enableBackgroundFetching = enabled != null ? enabled : true;
  }

  return $.enableBackgroundFetching;
}
