import Toybox.Lang;

using Toybox.Application.Storage;

(:glance)
function getHasSubscription() as Boolean {
  var storageValue = Storage.getValue("hasSubscription") as Boolean?;

  return storageValue != null ? storageValue : false;
}

(:background)
function setHasSubscription(hasSubscription as Boolean) as Void {
  Storage.setValue("hasSubscription", hasSubscription);
}
