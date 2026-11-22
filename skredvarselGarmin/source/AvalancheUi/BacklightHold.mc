import Toybox.Lang;

using Toybox.Attention;

module AvalancheUi {
  // Keeps the backlight on while long text scrolls, so it can be read to the
  // end.
  //
  // Calling Attention.backlight repeatedly holds the backlight on, but watches
  // with burn in protection throw when it is held too long (about a minute),
  // so the hold stops at the first exception.
  class BacklightHold {
    // The shortest backlight timeout on watches is a few seconds.
    private const TICKS_BETWEEN_CALLS = 10;

    private var _isActive as Boolean = false;
    private var _ticks as Number = 0;

    public function start() as Void {
      _isActive = Attention has :backlight;
      _ticks = 0;
    }

    public function stop() as Void {
      _isActive = false;
    }

    public function onTick() as Void {
      if (!_isActive) {
        return;
      }

      _ticks += 1;
      if (_ticks < TICKS_BETWEEN_CALLS) {
        return;
      }
      _ticks = 0;

      try {
        Attention.backlight(true);
      } catch (ex) {
        _isActive = false;
      }
    }
  }
}
