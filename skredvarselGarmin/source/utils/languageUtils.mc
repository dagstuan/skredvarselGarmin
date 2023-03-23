import Toybox.Lang;

using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.WatchUi as Ui;

(:glance)
var useWatchLanguage as Boolean?;

(:glance)
function getUseWatchLanguage() as Boolean {
  if ($.useWatchLanguage == null) {
    $.useWatchLanguage = Properties.getValue("useWatchLanguage");
  }

  return $.useWatchLanguage;
}

(:glance)
function getOrLoadResourceString(
  defaultString as String,
  resourceRef as Symbol
) {
  if ($.getUseWatchLanguage() == true) {
    var strings = $.Rez.Strings as Dictionary<Symbol, Symbol>;

    return Application.loadResource(strings[resourceRef]);
  }

  return defaultString;
}

(:background)
function getForecastLanguage() as Number {
  return Properties.getValue("forecastLanguage");
}
