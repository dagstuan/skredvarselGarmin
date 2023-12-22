import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;

module AvalancheUi {
  typedef MainTextSettings as {
    :text as String,
    :emergencyWarning as String?,
    :width as Numeric,
    :height as Numeric,
  };

  class MainText {
    private var _text as String;
    private var _hasEmergencyWarning as Boolean;
    private var _emergencyWarning as String?;
    private var _width as Numeric;
    private var _height as Numeric;
    private var _paddingTopBottom as Numeric;
    private var _paddingLeftRightEmergencyWarningText as Numeric;

    private var _font = Gfx.FONT_SYSTEM_XTINY;
    private var _fontHeight = Gfx.getFontHeight(_font);

    private var _emergencyWarningIconWidth as Numeric?;
    private var _emergencyWarningHeight as Numeric = 0.0;
    private var _emergencyWarningContentWidth as Numeric = 0.0;

    private var _emergencyWarningIcon as Ui.BitmapResource?;
    private var _emergencyWarningText as AvalancheUi.ScrollingText?;
    private var _mainText as AvalancheUi.ScrollingText?;

    public function initialize(settings as MainTextSettings) {
      _text = settings[:text];
      _emergencyWarning = settings[:emergencyWarning];
      _hasEmergencyWarning = _emergencyWarning != null;
      _width = settings[:width];
      _height = settings[:height];
      _paddingLeftRightEmergencyWarningText = _width * 0.02;
      _paddingTopBottom = _height * 0.05;
    }

    public function onShow() as Void {
      if (_emergencyWarningText != null) {
        _emergencyWarningText.onShow();
      }

      if (_mainText != null) {
        _mainText.onShow();
      }
    }

    public function onHide() as Void {
      if (_emergencyWarningText != null) {
        _emergencyWarningText.onHide();
      }

      if (_mainText != null) {
        _mainText.onHide();
      }
    }

    public function onTick() as Void {
      if (_emergencyWarningText != null) {
        _emergencyWarningText.onTick();
      }

      if (_mainText != null) {
        _mainText.onTick();
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      y0 += _paddingTopBottom;

      if (_hasEmergencyWarning) {
        if (_emergencyWarningIcon == null || _emergencyWarningText == null) {
          _emergencyWarningIcon =
            Ui.loadResource($.Rez.Drawables.EmergencyWarningIcon) as
            Ui.BitmapResource;

          _emergencyWarningIconWidth = _emergencyWarningIcon.getWidth();

          var iconHeight = _emergencyWarningIcon.getHeight();
          if (_fontHeight > iconHeight) {
            _emergencyWarningHeight = _fontHeight;
          } else {
            _emergencyWarningHeight = iconHeight;
          }

          var textWidth = dc.getTextWidthInPixels(_emergencyWarning, _font);
          var textContainerWidth =
            _width -
            _emergencyWarningIconWidth -
            _paddingLeftRightEmergencyWarningText * 2;

          _emergencyWarningContentWidth =
            _emergencyWarningIconWidth +
            _paddingLeftRightEmergencyWarningText +
            textWidth;

          _emergencyWarningText = new ScrollingText({
            :text => _emergencyWarning,
            :containerWidth => textContainerWidth,
            :containerHeight => _emergencyWarningHeight,
            :font => Gfx.FONT_XTINY,
            :color => Gfx.COLOR_BLACK,
            :backgroundColor => Gfx.COLOR_WHITE,
            :yAlignment => Y_ALIGN_CENTER,
            :xAlignment => X_ALIGN_LEFT,
          });
        }

        var textX0 = x0;
        if (_emergencyWarningContentWidth < _width) {
          textX0 = x0 + (_width - _emergencyWarningContentWidth) / 2;
        }

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
        dc.fillRectangle(x0, y0, _width, _emergencyWarningHeight);

        dc.drawBitmap(textX0, y0, _emergencyWarningIcon);

        _emergencyWarningText.draw(
          dc,
          textX0 +
            _emergencyWarningIconWidth +
            _paddingLeftRightEmergencyWarningText,
          y0
        );

        y0 += _paddingTopBottom + _emergencyWarningHeight;
      }

      if (_mainText == null) {
        var containerHeight = _height - _paddingTopBottom * 2;
        if (_emergencyWarningHeight > 0) {
          containerHeight -= _emergencyWarningHeight + _paddingTopBottom;
        }

        _mainText = new ScrollingText({
          :text => _text,
          :containerWidth => _width,
          :containerHeight => containerHeight,
          :font => Gfx.FONT_SYSTEM_XTINY,
          :scrollDirection => SCROLL_DIRECTION_VERTICAL,
        });
      }

      _mainText.draw(dc, x0, y0);
    }
  }
}
