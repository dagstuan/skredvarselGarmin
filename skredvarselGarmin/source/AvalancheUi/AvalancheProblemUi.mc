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

  return Lang.format("$1$ $2$", [$.lowercaseFirstChar(sizeText), size]);
}

module AvalancheUi {
  typedef AvalancheProblemSettings as {
    :dc as Gfx.Dc,
    :problem as AvalancheProblem,
    :width as Numeric,
    :height as Numeric,
  };

  public class AvalancheProblemUi {
    private const PROBLEM_BLOCK_WIDTH_RATIO = 0.94;
    private const ICON_SIZE_HEIGHT_RATIO = 0.55;
    private const ICON_PADDING_RATIO = 0.35;
    private const DANGER_LINE_GAP_RATIO = 0.6;

    private var _problemText as String;
    private var _exposedHeights as Array<Number>;
    private var _validExpositions as String;
    private var _dangerLevel as Number;

    private var _availableWidth as Number = 0;
    private var _availableHeight as Number = 0;
    private var _textHeight as Number = 0;
    private var _headingGap as Number = 0;
    private var _iconRowHeight as Number = 0;
    private var _dangerLineGap as Number = 0;
    private var _textContainerWidth as Number = 0;
    private var _problemBlockWidth as Number = 0;
    private var _problemBlockHeight as Number = 0;

    private var _dangerFillColor as Gfx.ColorType;
    private var _nonDangerFillColor as Gfx.ColorType;

    private var _iconRowAvailableHeight as Number;
    private var _paddingBetweenElements as Number = 0;

    private var _dangerLevelWidth = 4;
    private var _hasExposedHeightZones as Boolean = false;
    private var _iconRowWidth as Number = 0;

    private var _problemTextElement as AvalancheUi.ScrollingText?;

    private var _validExpositionsUi as AvalancheUi.ValidExpositions?;
    private var _exposedHeightUi as AvalancheUi.ExposedHeight?;
    private var _exposedHeightTextUi as AvalancheUi.ExposedHeightText?;

    public function initialize(settings as AvalancheProblemSettings) {
      var problem = settings[:problem];

      var typeName = $.getProblemTypeName(problem["typeId"]);
      if (
        problem["triggerSensitivity"] &&
        problem["propagation"] &&
        problem["destructiveSize"]
      ) {
        _problemText = Lang.format("$1$ - $2$ ($3$).", [
          typeName,
          getTriggerText(problem["triggerSensitivity"], problem["propagation"]),
          getDestructiveSizeText(problem["destructiveSize"]),
        ]);
      } else {
        _problemText = typeName;
      }

      var exposedHeightZones = problem["exposedHeightZones"];
      if (exposedHeightZones != null) {
        _exposedHeights = [
          0,
          0,
          $.exposedHeightZonesToFill(exposedHeightZones),
        ];
        _hasExposedHeightZones = true;
      } else {
        _exposedHeights = problem["exposedHeights"];
        _hasExposedHeightZones = false;
      }
      _validExpositions = problem["validExpositions"];
      _dangerLevel = problem["dangerLevel"];

      _availableWidth = settings[:width].toNumber();
      _availableHeight = settings[:height].toNumber();
      _textHeight = Gfx.getFontHeight(Gfx.FONT_XTINY);
      _headingGap = (_textHeight * 0.3).toNumber();
      if (_headingGap < 1) {
        _headingGap = 1;
      }

      _iconRowAvailableHeight = _availableHeight - _textHeight - _headingGap;
      _dangerFillColor = Gfx.COLOR_RED;
      _nonDangerFillColor = Gfx.COLOR_LT_GRAY;

      setupUiElements(settings[:dc]);
    }

    public function onShow() as Void {
      if (_problemTextElement != null) {
        _problemTextElement.reset();
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
      _problemBlockWidth = (
        _availableWidth * PROBLEM_BLOCK_WIDTH_RATIO
      ).toNumber();
      setupGraphicElements(dc);

      _textContainerWidth =
        _problemBlockWidth - _dangerLevelWidth - _dangerLineGap;
      if (_textContainerWidth < 1) {
        _textContainerWidth = 1;
      }

      _problemTextElement = new ScrollingText({
        :dc => dc,
        :text => _problemText,
        :containerWidth => _textContainerWidth,
        :containerHeight => _textHeight,
        :scrollSpeed => 3,
        :xAlignment => X_ALIGN_LEFT,
        :font => Gfx.FONT_XTINY,
      });

      _problemBlockHeight = _textHeight + _headingGap + _iconRowHeight;
    }

    private function setupGraphicElements(dc as Gfx.Dc) as Void {
      var maxAllowedIconRowWidth =
        _problemBlockWidth > 0 ? _problemBlockWidth : _availableWidth;
      var iconSize = (
        _iconRowAvailableHeight * ICON_SIZE_HEIGHT_RATIO
      ).toNumber();
      if (iconSize < 1) {
        iconSize = 1;
      }

      for (var i = 0; i < 6; i++) {
        _paddingBetweenElements = (iconSize * ICON_PADDING_RATIO).toNumber();
        if (_paddingBetweenElements < 3) {
          _paddingBetweenElements = 3;
        }

        _dangerLineGap = (
          _paddingBetweenElements * DANGER_LINE_GAP_RATIO
        ).toNumber();
        if (_dangerLineGap < 2) {
          _dangerLineGap = 2;
        }

        _validExpositionsUi = new AvalancheUi.ValidExpositions({
          :validExpositions => _validExpositions,
          :dangerFillColor => _dangerFillColor,
          :nonDangerFillColor => _nonDangerFillColor,
          :radius => iconSize / 2,
        });

        _exposedHeightUi = new AvalancheUi.ExposedHeight({
          :exposedHeight1 => _exposedHeights[0],
          :exposedHeight2 => _exposedHeights[1],
          :exposedHeightFill => _exposedHeights[2],
          :dangerFillColor => _dangerFillColor,
          :nonDangerFillColor => _nonDangerFillColor,
          :size => iconSize,
        });
        var exposedHeightUiSize = getExposedHeightUiSize();

        _exposedHeightTextUi = null;
        if (!_hasExposedHeightZones) {
          _exposedHeightTextUi = new AvalancheUi.ExposedHeightText({
            :dc => dc,
            :exposedHeight1 => _exposedHeights[0],
            :exposedHeight2 => _exposedHeights[1],
            :exposedHeightFill => _exposedHeights[2],
            :dangerFillColor => _dangerFillColor,
            :maxWidth => exposedHeightUiSize,
            :maxHeight => exposedHeightUiSize,
          });
        }

        _iconRowHeight = $.max([
          _validExpositionsUi.getTotalHeight(),
          exposedHeightUiSize,
        ]);
        _iconRowWidth = getRowWidth();

        var totalWidth = _dangerLevelWidth + _dangerLineGap + _iconRowWidth;
        var totalHeight = _textHeight + _headingGap + _iconRowHeight;
        if (
          totalWidth <= maxAllowedIconRowWidth &&
          totalHeight <= _availableHeight
        ) {
          break;
        }

        var widthScale =
          maxAllowedIconRowWidth.toFloat() / totalWidth.toFloat();
        var heightScale = _availableHeight.toFloat() / totalHeight.toFloat();
        var scale = widthScale < heightScale ? widthScale : heightScale;
        if (scale >= 1.0f) {
          break;
        }

        iconSize = (iconSize.toFloat() * scale).toNumber();
      }
    }

    public function draw(dc as Gfx.Dc, x0 as Numeric, y0 as Numeric) as Void {
      var validExpositionsUiSize = getValidExpositionsUiSize();
      var exposedHeightUiSize = getExposedHeightUiSize();
      var problemBlockXOffset = (_availableWidth - _problemBlockWidth) / 2;
      var problemBlockYOffset = (_availableHeight - _problemBlockHeight) / 2;
      var problemBlockX0 = x0 + problemBlockXOffset;
      var problemBlockY0 = y0 + problemBlockYOffset;
      var textX0 = problemBlockX0 + _dangerLevelWidth + _dangerLineGap;
      var iconRowX0 = textX0 + (_textContainerWidth - _iconRowWidth) / 2;
      var bottomY = problemBlockY0 + _textHeight + _headingGap + _iconRowHeight;

      if ($.DrawOutlines) {
        $.drawOutline(
          dc,
          problemBlockX0,
          problemBlockY0,
          _problemBlockWidth,
          _problemBlockHeight
        );
      }

      drawDangerLevel(dc, problemBlockX0, problemBlockY0);

      _problemTextElement.draw(dc, textX0, problemBlockY0);

      var curX = iconRowX0;
      _validExpositionsUi.draw(dc, curX, bottomY - validExpositionsUiSize);

      curX += validExpositionsUiSize + _paddingBetweenElements;
      var exposedHeightY0 = bottomY - exposedHeightUiSize;
      _exposedHeightUi.draw(dc, curX, exposedHeightY0);

      curX += exposedHeightUiSize + _paddingBetweenElements;
      if (_exposedHeightTextUi != null) {
        _exposedHeightTextUi.draw(dc, curX, exposedHeightY0);
      }
    }

    private function drawDangerLevel(
      dc as Gfx.Dc,
      x0 as Numeric,
      y0 as Numeric
    ) {
      var color = $.colorize(_dangerLevel);
      dc.setColor(color, Gfx.COLOR_TRANSPARENT);

      dc.fillRectangle(x0, y0, _dangerLevelWidth, _problemBlockHeight);
    }

    private function getValidExpositionsUiSize() as Numeric {
      if (_validExpositionsUi == null) {
        return 0;
      }

      return _validExpositionsUi.getSize();
    }

    private function getExposedHeightUiSize() as Numeric {
      if (_exposedHeightUi == null) {
        return 0;
      }

      return _exposedHeightUi.getSize();
    }

    private function getExposedHeightTextUiWidth() as Numeric {
      if (_exposedHeightTextUi == null) {
        return 0;
      }

      return _exposedHeightTextUi.getWidth();
    }

    private function getRowWidth() as Number {
      var totalWidth = getValidExpositionsUiSize() + getExposedHeightUiSize();

      if (_hasExposedHeightZones) {
        return totalWidth + _paddingBetweenElements;
      }

      return (
        totalWidth + getExposedHeightTextUiWidth() + _paddingBetweenElements * 2
      );
    }
  }
}
