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
    return Application.loadResource(($.Rez.Strings as Object)[resourceRef]);
  }

  return defaultString;
}

(:background)
function getForecastLanguage() as Number {
  try {
    return Properties.getValue("forecastLanguage") as Number;
  } catch (ex) {
    return 1; // assume Norwegian if no value is found.
  }
}
