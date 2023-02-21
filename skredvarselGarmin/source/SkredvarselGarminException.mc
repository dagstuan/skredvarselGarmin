using Toybox.Lang;

class SkredvarselGarminException extends Lang.Exception {
  function initialize(message as Lang.String) {
    Exception.initialize();
    self.mMessage = message;
  }
}
