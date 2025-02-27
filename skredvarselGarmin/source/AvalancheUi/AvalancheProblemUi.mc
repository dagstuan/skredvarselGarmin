import Toybox.Lang;

using Toybox.Graphics as Gfx;

function getTriggerSensitivityText(triggerSensitivity as Number) as String {
  if (triggerSensitivity == 0) {
    return $.getOrLoadResourceString("Ikke gitt", :TriggerSensitivityNotGiven);
  } else if (triggerSensitivity == 10) {
    return $.getOrLoadResourceString(
      "Svært vanskelig å løse ut",
      :TriggerSensitivityVeryHardToTrigger
    );
  } else if (triggerSensitivity == 20) {
    return $.getOrLoadResourceString(
      "Vanskelig å løse ut",
      :TriggerSensitivityHardToTrigger
    );
  } else if (triggerSensitivity == 30) {
    return $.getOrLoadResourceString(
      "Lett å løse ut",
      :TriggerSensitivityEasyToTrigger
    );
  } else if (triggerSensitivity == 40) {
    return $.getOrLoadResourceString(
      "Svært lett å løse ut",
      :TriggerSensitivityVeryEasyToTrigger
    );
  } else if (triggerSensitivity == 45) {
    return $.getOrLoadResourceString(
      "Naturlig utløst",
      :TriggerSensitivityNaturallyTriggered
    );
  }

  throw new SkredvarselGarminException(
    "Unknown trigger sensitivity: " + triggerSensitivity
  );
}

function getPropagationText(propagation as Number) as String {
  if (propagation == 0) {
    return $.getOrLoadResourceString("Ikke gitt", :PropagationNotGiven);
  } else if (propagation == 1) {
    return $.getOrLoadResourceString(
      "Få bratte heng",
      :PropagationFewSteepSlopes
    );
  } else if (propagation == 2) {
    return $.getOrLoadResourceString(
      "Noen bratte heng",
      :PropagationSomeSteepSlopes
    );
  } else if (propagation == 3) {
    return $.getOrLoadResourceString(
      "Mange bratte heng",
      :PropagationManySteepSlopes
    );
  }

  throw new SkredvarselGarminException("Unknown propagation: " + propagation);
}

function getTriggerText(
  triggerSensitivity as Number,
  propagation as Number
) as String {
  return Lang.format("$1$ $2$ $3$", [
    getTriggerSensitivityText(triggerSensitivity),
    $.getOrLoadResourceString("i", :In),
    $.lowercaseFirstChar(getPropagationText(propagation)),
  ]);
}

function getDestructiveSizeText(size as Number) as String {
  var sizeText = $.getOrLoadResourceString("Str", :Size);

  return Lang.format("$1$ $2$", [sizeText, size]);
}

module AvalancheUi {
  typedef AvalancheProblemSettings as {
    :problem as AvalancheProblem,
    :locX as Numeric,
    :locY as Numeric,
    :width as Numeric,
    :height as Numeric,
    :dangerFillColor as Gfx.ColorType,
    :nonDangerFillColor as Gfx.ColorType,
  };

  public class AvalancheProblemUi {
    private var _problemText as String;
    private var _exposedHeights as Array<Number>;
    private var _validExpositions as String;
    private var _dangerLevel as Number;

    private var _width as Numeric;
    private var _height as Numeric;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    private var _elemMaxWidth as Number;
    private var _elemMaxHeight as Number;
    private var _paddingLeftRight as Number = 0;
    private var _paddingBetweenElements as Number = 0;

    private var _dangerLevelWidth = 4;

    private var _problemTextElement as AvalancheUi.ScrollingText?;

    private var _validExpositionsUi as AvalancheUi.ValidExpositions?;
    private var _validExpositionsUiSize as Numeric = 0;
    private var _exposedHeightUi as AvalancheUi.ExposedHeight?;
    private var _exposedHeightUiSize as Numeric = 0;
    private var _exposedHeightTextUi as AvalancheUi.ExposedHeightText?;
    private var _exposedHeightTextUiWidth as Numeric = 0;

    public function initialize(settings as AvalancheProblemSettings) {
      var problem = settings[:problem];

      var typeName = problem["typeName"];
      if (
        problem["triggerSensitivity"] &&
        problem["propagation"] &&
        problem["destructiveSize"]
      ) {
        _problemText = Lang.format("$1$ - $2$ - $3$", [
          typeName,
          getTriggerText(problem["triggerSensitivity"], problem["propagation"]),
          getDestructiveSizeText(problem["destructiveSize"]),
        ]);
      } else {
        _problemText = typeName;
      }

      _exposedHeights = problem["exposedHeights"];
      _validExpositions = problem["validExpositions"];
      _dangerLevel = problem["dangerLevel"];

      _width = settings[:width];
      _height = settings[:height];

      var deviceScreenWidth = $.getDeviceScreenWidth();
      if (deviceScreenWidth > 240) {
        _paddingLeftRight = (_width * 0.08).toNumber();
      }

      var minPaddingBetweenElements = (_width * 0.04).toNumber();
      _elemMaxHeight = (_height * 0.75).toNumber();
      _elemMaxWidth = (
        (_width - _paddingLeftRight * 2 - minPaddingBetweenElements * 3) /
        3
      ).toNumber();

      _dangerFillColor = Gfx.COLOR_RED;
      _nonDangerFillColor = Gfx.COLOR_LT_GRAY;

      setupUiElements(settings[:dc]);
    }

    public function onShow() as Void {
      if (_problemTextElement != null) {
        _problemTextElement.onShow();
      }
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.onShow();
      }
    }

    public function onHide() as Void {
      if (_problemTextElement != null) {
        _problemTextElement.onHide();
      }
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.onHide();
      }
    }

    public function onTick() as Void {
      if (_problemTextElement != null) {
        _problemTextElement.onTick();
      }
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.onTick();
      }
    }

    private function setupUiElements(dc as Gfx.Dc) {
      _problemTextElement = new ScrollingText({
        :dc => dc,
        :text => _problemText,
        :containerWidth => _width,
        :containerHeight => _height * 0.25,
        :scrollSpeed => 3,
        :font => Gfx.FONT_XTINY,
      });

      var maxSize = $.min(_elemMaxWidth, _elemMaxHeight);

      _validExpositionsUi = new AvalancheUi.ValidExpositions({
        :validExpositions => _validExpositions,
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :radius => maxSize / 2,
      });
      _validExpositionsUiSize = _validExpositionsUi.getSize();

      _exposedHeightUi = new AvalancheUi.ExposedHeight({
        :exposedHeight1 => _exposedHeights[0],
        :exposedHeight2 => _exposedHeights[1],
        :exposedHeightFill => _exposedHeights[2],
        :dangerFillColor => _dangerFillColor,
        :nonDangerFillColor => _nonDangerFillColor,
        :size => maxSize * 0.9,
      });
      _exposedHeightUiSize = _exposedHeightUi.getSize();

      _exposedHeightTextUi = new AvalancheUi.ExposedHeightText({
        :dc => dc,
        :exposedHeight1 => _exposedHeights[0],
        :exposedHeight2 => _exposedHeights[1],
        :exposedHeightFill => _exposedHeights[2],
        :dangerFillColor => _dangerFillColor,
        :maxWidth => _elemMaxWidth,
        :maxHeight => _elemMaxHeight,
      });
      _exposedHeightTextUiWidth = _exposedHeightTextUi.getWidth();

      var totalElementWidth =
        _validExpositionsUiSize +
        _exposedHeightUiSize +
        _exposedHeightTextUiWidth +
        _dangerLevelWidth;

      _paddingBetweenElements =
        (_width - _paddingLeftRight * 2 - totalElementWidth) / 3;
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      _problemTextElement.draw(dc, x0, y0);

      var elemX0 = x0 + _paddingLeftRight;
      var elemY0 = y0 + _height - _elemMaxHeight;

      if ($.DrawOutlines) {
        $.drawOutline(
          dc,
          elemX0,
          elemY0,
          _width - _paddingLeftRight * 2,
          _elemMaxHeight
        );
      }

      // x0 and y0 for expositions are the center of the circle.
      var validExpositionsUiShiftY =
        _elemMaxHeight / 2 - _validExpositionsUiSize / 2;
      _validExpositionsUi.draw(dc, elemX0, elemY0 + validExpositionsUiShiftY);

      elemX0 += _validExpositionsUiSize + _paddingBetweenElements;
      var exposedHeightUiShiftY = _elemMaxHeight / 2 - _exposedHeightUiSize / 2;
      _exposedHeightUi.draw(dc, elemX0, elemY0 + exposedHeightUiShiftY);

      elemX0 += _exposedHeightUiSize + _paddingBetweenElements;
      _exposedHeightTextUi.draw(dc, elemX0, elemY0);

      elemX0 += _exposedHeightTextUiWidth + _paddingBetweenElements;
      drawDangerLevel(dc, elemX0, elemY0);
    }

    private function drawDangerLevel(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      var color = $.colorize(_dangerLevel);
      dc.setColor(color, Gfx.COLOR_TRANSPARENT);

      var size = $.min(_elemMaxWidth, _elemMaxHeight);

      dc.fillRectangle(
        x0,
        y0 + _elemMaxHeight / 2 - size / 2,
        _dangerLevelWidth,
        size
      );
    }
  }
}
