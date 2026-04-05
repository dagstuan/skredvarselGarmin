import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.WatchUi as Ui;

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

// Renders a single avalanche problem as an inline horizontal row:
// [scrolling problem text]
// [problem type icon] [aspect rose] [exposed height icon/text]
class DatafieldProblemUi {
  private const EXPOSED_HEIGHT_ICON_MS = 5000;
  private const EXPOSED_HEIGHT_TEXT_MS = 12000;

  private var _height as Number;
  private var _headingFont as Gfx.FontType = Gfx.FONT_XTINY;
  private var _headingHeight as Number;
  private var _headingGap as Number;
  private var _dangerLevel as Number;
  private var _dangerLineWidth as Number = 4;
  private var _dangerLineGap as Number;

  private var _problemTextElement as AvalancheUi.ScrollingText;
  private var _problemIcon as Ui.BitmapResource;
  private var _problemIconSize as Number = 0;
  private var _validExpositionsUi as AvalancheUi.ValidExpositions;
  private var _exposedHeightUi as AvalancheUi.ExposedHeight?;
  private var _exposedHeightTextUi as AvalancheUi.ExposedHeightText?;

  private var _iconSize as Number;
  private var _iconRowHeight as Number;
  private var _gap as Number;
  private var _iconRowWidth as Number = 0;
  private var _inline as Boolean = false;
  private var _exposedHeightToggleStartMs as Number = 0;
  private var _exposedHeightTextWasVisible as Boolean = false;

  public function initialize(
    dc as Gfx.Dc,
    problem as AvalancheProblem,
    iconScale as Float,
    inline as Boolean,
    numProblems as Number
  ) {
    _inline = inline;

    var dangerFillColor = Gfx.COLOR_RED;
    var nonDangerFillColor = Gfx.COLOR_LT_GRAY;
    var typeId = problem["typeId"] as Number;
    _dangerLevel = problem["dangerLevel"] as Number;
    _headingHeight = Gfx.getFontHeight(_headingFont);

    var headingGapFactor = inline ? 0.1f : numProblems == 1 ? 0.3f : 0.15f;
    _headingGap = (_headingHeight * headingGapFactor).toNumber();
    if (_headingGap < 1) {
      _headingGap = 1;
    }

    var typeName = $.getProblemTypeName(typeId);
    var problemText;
    if (
      problem["triggerSensitivity"] &&
      problem["propagation"] &&
      problem["destructiveSize"]
    ) {
      problemText = Lang.format("$1$ - $2$ ($3$).", [
        typeName,
        $.getTriggerText(problem["triggerSensitivity"], problem["propagation"]),
        $.getDestructiveSizeText(problem["destructiveSize"]),
      ]);
    } else {
      problemText = typeName;
    }

    // Use the large resource when scaling up to avoid pixelation
    var problemIconResource =
      iconScale > 1.0f
        ? $.getIconResourceForProblemTypeLarge(typeId)
        : $.getIconResourceForProblemType(typeId);
    _problemIcon = Ui.loadResource(problemIconResource) as Ui.BitmapResource;

    // _iconSize drives the aspect rose and exposed height icon sizes
    var baseIcon =
      Ui.loadResource($.getIconResourceForProblemType(typeId)) as
      Ui.BitmapResource;
    _iconSize = (baseIcon.getHeight() * iconScale).toNumber();

    // Draw the problem type icon at its native size (no scaling needed)
    _problemIconSize = _problemIcon.getHeight();

    var gapFactor = inline ? 0.2f : 0.35f;
    _gap =
      (_iconSize * gapFactor).toNumber() < 3
        ? 3
        : (_iconSize * gapFactor).toNumber();
    _dangerLineGap = (_gap * 0.6).toNumber();
    if (_dangerLineGap < 2) {
      _dangerLineGap = 2;
    }

    var exposedHeights =
      problem["exposedHeightZones"] != null
        ? [
            0,
            0,
            $.exposedHeightZonesToFill(
              problem["exposedHeightZones"] as Array<Boolean>
            ),
          ]
        : problem["exposedHeights"] as Array<Number>;

    _validExpositionsUi = new AvalancheUi.ValidExpositions({
      :validExpositions => problem["validExpositions"] as String,
      :dangerFillColor => dangerFillColor,
      :nonDangerFillColor => nonDangerFillColor,
      :radius => _iconSize / 2,
    });

    _exposedHeightUi = new AvalancheUi.ExposedHeight({
      :exposedHeight1 => exposedHeights[0],
      :exposedHeight2 => exposedHeights[1],
      :exposedHeightFill => exposedHeights[2],
      :dangerFillColor => dangerFillColor,
      :nonDangerFillColor => nonDangerFillColor,
      :size => _iconSize,
    });

    var expositionsSize = _validExpositionsUi.getSize();
    var expositionsTotalH = _validExpositionsUi.getTotalHeight();
    var exposedHeightSize = (
      _exposedHeightUi as AvalancheUi.ExposedHeight
    ).getSize();
    _iconRowHeight = $.max([_iconSize, expositionsTotalH, exposedHeightSize]);

    var useExposedHeightText =
      numProblems != 3 && problem["exposedHeightZones"] == null;
    if (useExposedHeightText) {
      _exposedHeightTextUi = new AvalancheUi.ExposedHeightText({
        :dc => dc,
        :exposedHeight1 => exposedHeights[0],
        :exposedHeight2 => exposedHeights[1],
        :exposedHeightFill => exposedHeights[2],
        :dangerFillColor => dangerFillColor,
        :maxWidth => exposedHeightSize,
        :maxHeight => exposedHeightSize,
      });
    }

    _iconRowWidth =
      _problemIconSize + _gap + expositionsSize + _gap + exposedHeightSize;

    _problemTextElement = new AvalancheUi.ScrollingText({
      :dc => dc,
      :text => problemText,
      :containerWidth => _iconRowWidth,
      :containerHeight => _headingHeight,
      :scrollSpeed => 3,
      :font => _headingFont,
      :color => Gfx.COLOR_WHITE,
      :backgroundColor => Gfx.COLOR_BLACK,
    });

    _height = _headingHeight + _headingGap + _iconRowHeight;
  }

  public function onShow() as Void {
    _exposedHeightToggleStartMs = System.getTimer();
    _exposedHeightTextWasVisible = false;
    _problemTextElement.onShow();
  }

  private function shouldShowExposedHeightText() as Boolean {
    if (_exposedHeightTextUi == null) {
      return false;
    }

    var now = System.getTimer();
    if (now < _exposedHeightToggleStartMs) {
      _exposedHeightToggleStartMs = now;
      return false;
    }

    var elapsedMs =
      (now - _exposedHeightToggleStartMs) %
      (EXPOSED_HEIGHT_ICON_MS + EXPOSED_HEIGHT_TEXT_MS);
    return elapsedMs >= EXPOSED_HEIGHT_ICON_MS;
  }

  public function getScrollingTextCycleTicks() as Number {
    return _problemTextElement.getCycleTicks();
  }

  public function setScrollingTextCycleTicks(cycleTicks as Number) as Void {
    _problemTextElement.setCycleTicks(cycleTicks);
  }

  public function getTotalWidth() as Number {
    return _dangerLineWidth + _dangerLineGap + _iconRowWidth;
  }

  public function getTotalHeight() as Number {
    return _height;
  }

  public function draw(
    dc as Gfx.Dc,
    x0 as Number,
    y0 as Number,
    fieldWidth as Number
  ) as Void {
    var problemX;
    var iconRowX;
    var dangerLineX;
    if (_inline) {
      // Inline mode: x0 is the left edge of the full problem block.
      problemX = x0;
    } else {
      // Normal mode: center the entire problem block, including the danger bar.
      problemX = x0 + (fieldWidth - getTotalWidth()) / 2;
    }

    dangerLineX = problemX;
    iconRowX = problemX + _dangerLineWidth + _dangerLineGap;

    if ($.DrawOutlines) {
      $.drawOutline(dc, problemX, y0, getTotalWidth(), _height);
    }

    var dangerColor = $.colorize(_dangerLevel);
    dc.setColor(dangerColor, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(dangerLineX, y0, _dangerLineWidth, _height);

    _problemTextElement.draw(dc, iconRowX, y0);

    var iconRowY = y0 + _headingHeight + _headingGap;
    var bottomY = iconRowY + _iconRowHeight;

    var curX = iconRowX;

    // Problem type icon
    dc.drawBitmap(curX, bottomY - _problemIconSize, _problemIcon);
    curX += _problemIconSize + _gap;

    // Aspect rose — center the circle, "N" label extends above
    var expositionsSize = _validExpositionsUi.getSize();
    _validExpositionsUi.draw(dc, curX, bottomY - expositionsSize);
    curX += expositionsSize + _gap;

    var showExposedHeightText = shouldShowExposedHeightText();
    if (showExposedHeightText && !_exposedHeightTextWasVisible) {
      (_exposedHeightTextUi as AvalancheUi.ExposedHeightText).onShow();
    }
    _exposedHeightTextWasVisible = showExposedHeightText;

    var exposedHeightSize = (
      _exposedHeightUi as AvalancheUi.ExposedHeight
    ).getSize();
    if (showExposedHeightText) {
      (_exposedHeightTextUi as AvalancheUi.ExposedHeightText).draw(
        dc,
        curX,
        bottomY - exposedHeightSize
      );
    } else {
      (_exposedHeightUi as AvalancheUi.ExposedHeight).draw(
        dc,
        curX,
        bottomY - exposedHeightSize
      );
    }
  }
}
