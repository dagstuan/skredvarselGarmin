import Toybox.Lang;

using Toybox.Application;
using Toybox.Application.Properties;

(:glance)
var useWatchLanguage as Boolean?;

(:glance)
function getUseWatchLanguage() as Boolean {
  if ($.useWatchLanguage == null) {
    $.useWatchLanguage =
      Properties.getValue("useWatchLanguage") as Lang.Boolean;
  }

  return $.useWatchLanguage;
}

(:glance,:typecheck(false))
function getOrLoadResourceString(
  defaultString as String,
  resourceRef as Symbol
) {
  if ($.getUseWatchLanguage() == true) {
    return Application.loadResource($.Rez.Strings[resourceRef]);
  }

  return defaultString;
}

(:background)
function getForecastLanguage() as Number {
  var language = Properties.getValue("forecastLanguage") as Number?;

  return language != null ? language : 1; // assume Norwegian if no value is found.
}
