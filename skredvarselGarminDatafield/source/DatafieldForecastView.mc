import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Activity;
using Toybox.Math;

class DatafieldForecastView {
  private var _locationDetailedForecast as
  DetailedWarningsForLocationResponse? = null;
  private var _detailedWarning as DetailedAvalancheWarning? = null;
  private var _isLoading as Boolean = false;
  private var _lastFetchTime as Number = 0;

  // Max 3 problems shown; when 3, problems 0+1 are rendered side-by-side
  private var _problemUis as Array<DatafieldProblemUi?> = [null, null, null];
  private var _numProblems as Number = 0;

  private var _regionNameScrollingText as AvalancheUi.ScrollingText? = null;
  private var _regionNameX0 as Numeric = 0;
  private var _noProblemView as DatafieldNoProblemView? = null;

  private var _updatedAtBitmap as Gfx.BufferedBitmap? = null;
  private var _updatedAtBitmapW as Numeric = 0;
  private var _updatedAtBitmapH as Numeric = 0;

  private var _fieldWidth as Number = 0;
  private var _fieldHeight as Number = 0;
  private var _isActivityRunning as Boolean = false;
  private var _needsFullRebuild as Boolean = false;

  public function onDataChanged() as Void {
    _needsFullRebuild = true;
  }

  public function onLayout(dc as Gfx.Dc) as Void {
    _fieldWidth = dc.getWidth();
    _fieldHeight = dc.getHeight();
    _loadDataFromStorage();
    _buildProblemUis(dc);
    _buildRegionNameText(dc);
    _syncScrollingTextCycles();
  }

  public function compute(info as Activity.Info) as Void {
    _isActivityRunning =
      info has :timerState && info.timerState == Activity.TIMER_STATE_ON;
    checkRegionAndFetchIfNeeded(info);
  }

  (:noForegroundRequest)
  public function checkRegionAndFetchIfNeeded(info as Activity.Info) as Void {}

  (:foregroundRequest)
  public function checkRegionAndFetchIfNeeded(info as Activity.Info) as Void {
    if (!$.canMakeWebRequest()) {
      if ($.Debug) {
        $.log(
          "checkRegionAndFetchIfNeeded: no web request available (bluetooth not connected?)."
        );
      }
      return;
    }

    if (_isLoading) {
      if ($.Debug) {
        $.log("checkRegionAndFetchIfNeeded: already loading, skipping.");
      }
      return;
    }

    var location =
      info.currentLocation != null
        ? info.currentLocation.toDegrees()
        : $.getLocation();

    if (location == null) {
      if ($.Debug) {
        $.log("checkRegionAndFetchIfNeeded: no location available.");
      }
      return;
    }

    var storedLocation = $.getStoredLocation();
    if (storedLocation != null) {
      var distanceKm = $.getDistanceInKilometers(storedLocation, location);

      if (distanceKm > 10.0f) {
        if ($.Debug) {
          $.log(
            Lang.format(
              "Moved $1$ km since last forecast location. Refetching.",
              [distanceKm.format("%.1f")]
            )
          );
        }

        _requestDetailedForecast(location);
        return;
      }
    }

    if (_locationDetailedForecast == null) {
      if ($.Debug) {
        $.log("checkRegionAndFetchIfNeeded: no cached data, fetching.");
      }
      _requestDetailedForecast(location);
      return;
    }

    // If data is stale by age, just refetch immediately without the region check
    var now = Time.now().value();
    if (now - _lastFetchTime > $.TIME_TO_CONSIDER_DATA_STALE) {
      if ($.Debug) {
        $.log("checkRegionAndFetchIfNeeded: data stale, fetching.");
      }
      _requestDetailedForecast(location);
      return;
    }
  }

  private function _requestDetailedForecast(
    location as [Lang.Double, Lang.Double]
  ) as Void {
    _isLoading = true;
    _lastFetchTime = Time.now().value();
    $.loadDetailedWarningsForLocation(
      location,
      method(:onDetailedForecastReceived),
      false
    );
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    AvalancheUi.tickScrollingTexts();

    if (_needsFullRebuild) {
      _needsFullRebuild = false;
      _loadDataFromStorage();
      _buildProblemUis(dc);
      _buildRegionNameText(dc);
      _syncScrollingTextCycles();
    }

    dc.setClip(0, 0, _fieldWidth, _fieldHeight);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    if (_locationDetailedForecast == null) {
      var msg;
      if (_isLoading) {
        msg = $.getOrLoadResourceString("Loading...", :Loading);
      } else if ($.getLocation() != null) {
        msg = $.getOrLoadResourceString(
          "Waiting for forecast...",
          :WaitingForForecast
        );
      } else {
        msg = $.getOrLoadResourceString(
          "Waiting for location...",
          :WaitingForLocation
        );
      }
      _drawCenteredText(dc, msg);
    } else {
      _drawForecast(dc);
    }
  }

  private function _buildRegionNameText(dc as Gfx.Dc) as Void {
    _regionNameScrollingText = null;
    _regionNameX0 = 0;

    if (_locationDetailedForecast == null) {
      return;
    }

    var regionId = _locationDetailedForecast["regionId"].toString();
    var regionName = $.getRegionName(regionId);
    var regionNameFont = Gfx.FONT_XTINY;
    var regionNameFontH = Gfx.getFontHeight(regionNameFont);

    var containerWidth = _fieldWidth;

    // On round screens, calculate the chord width at the text's Y position
    var screenWidth = $.getDeviceScreenWidth();
    var screenHeight = $.getDeviceScreenHeight();
    if (screenWidth == screenHeight && _fieldWidth >= screenWidth) {
      var startY = _getContentTopY();
      var textCenterY = startY + regionNameFontH / 2.0;

      var r = screenWidth / 2.0;
      var dy = _fieldHeight / 2.0 - textCenterY;
      if (dy < r) {
        var chordWidth = (2.0 * Math.sqrt(r * r - dy * dy)).toNumber();
        var padding = (_fieldWidth * 0.04).toNumber();
        chordWidth -= padding * 2;
        if (chordWidth < _fieldWidth) {
          containerWidth = chordWidth;
          _regionNameX0 = (_fieldWidth - containerWidth) / 2;
        }
      }
    }

    _regionNameScrollingText = new AvalancheUi.ScrollingText({
      :dc => dc,
      :text => regionName,
      :containerWidth => containerWidth,
      :containerHeight => regionNameFontH,
      :scrollSpeed => 2,
      :font => regionNameFont,
      :color => Gfx.COLOR_WHITE,
      :backgroundColor => Gfx.COLOR_BLACK,
    });

    _regionNameScrollingText.onShow();
  }

  private function _buildProblemUis(dc as Gfx.Dc) as Void {
    _problemUis = [null, null, null];
    _numProblems = 0;
    _noProblemView = null;
    _updatedAtBitmap = null;
    if (_detailedWarning == null) {
      return;
    }

    var problems =
      _detailedWarning["avalancheProblems"] as Array<AvalancheProblem>;

    // if ($.Debug) {
    //   problems = problems.slice(0, 1); // --- IGNORE --- Force one-problem layout for testing
    //   problems.add(problems[0]); // --- IGNORE --- Force three-problem layout for testing
    // }

    // Sort by dangerLevel descending (insertion sort) so most dangerous renders first
    for (var i = 1; i < problems.size(); i++) {
      var key = problems[i];
      var j = i - 1;
      while (
        j >= 0 &&
        ((problems[j] as AvalancheProblem)["dangerLevel"] as Number) <
          ((key as AvalancheProblem)["dangerLevel"] as Number)
      ) {
        problems[j + 1] = problems[j];
        j--;
      }
      problems[j + 1] = key;
    }

    _numProblems = $.min(problems.size(), 3);

    if (_numProblems == 0) {
      var regionId = (
        _locationDetailedForecast as DetailedWarningsForLocationResponse
      )["regionId"].toString();
      var regionName = $.getRegionName(regionId);
      var dangerLevel = _detailedWarning["dangerLevel"] as Number;
      _noProblemView = new DatafieldNoProblemView(
        dc,
        regionName,
        dangerLevel,
        _fieldWidth,
        _fieldHeight
      );
      _noProblemView.onShow();
      return;
    }

    var iconScale = _numProblems == 3 ? 0.85f : _numProblems == 1 ? 1.4f : 1.0f;
    for (var i = 0; i < _numProblems; i++) {
      var usesTightSpacing = _numProblems == 3 && i < 2;
      var headingGapFactor = usesTightSpacing
        ? 0.1f
        : _numProblems == 1
          ? 0.3f
          : 0.15f;
      var gapFactor = usesTightSpacing ? 0.2f : 0.35f;
      var problemUi = new DatafieldProblemUi(
        dc,
        problems[i] as AvalancheProblem,
        iconScale,
        headingGapFactor,
        gapFactor,
        _numProblems
      );
      problemUi.onShow();
      _problemUis[i] = problemUi;
    }
  }

  private function _getCenteredProblemX(
    problemUi as DatafieldProblemUi
  ) as Number {
    return (_fieldWidth - problemUi.getTotalWidth()) / 2;
  }

  private function _canEvaluateProblemActiveStateAtElevation(
    problem as AvalancheProblem
  ) as Boolean {
    var exposedHeightZones = problem["exposedHeightZones"] as Array<Boolean>?;
    var exposedHeights = problem["exposedHeights"] as Array<Number>?;

    return (
      exposedHeightZones == null &&
      exposedHeights != null &&
      exposedHeights.size() >= 3
    );
  }

  private function _isProblemActiveAtElevation(
    problem as AvalancheProblem,
    elevation as Float?
  ) as Boolean {
    if (elevation == null) {
      return false;
    }

    var exposedHeightZones = problem["exposedHeightZones"] as Array<Boolean>?;
    var absoluteExposedHeights = problem["exposedHeights"] as Array<Number>?;
    if (exposedHeightZones != null || absoluteExposedHeights == null) {
      return false;
    }

    if (absoluteExposedHeights.size() < 3) {
      return false;
    }

    var exposedHeight1 = absoluteExposedHeights[0];
    var exposedHeight2 = absoluteExposedHeights[1];
    var exposedHeightFill = absoluteExposedHeights[2];
    if (exposedHeightFill < 1 || exposedHeightFill > 4) {
      return false;
    }

    if (exposedHeightFill == 1) {
      return elevation >= exposedHeight1;
    } else if (exposedHeightFill == 2) {
      return elevation <= exposedHeight1;
    } else if (exposedHeightFill == 3) {
      return elevation >= exposedHeight1 || elevation <= exposedHeight2;
    } else if (exposedHeightFill == 4) {
      return elevation <= exposedHeight1 && elevation >= exposedHeight2;
    }

    return false;
  }

  private function _shouldRenderProblemInGrayscale(
    problemUi as DatafieldProblemUi,
    elevation as Float?
  ) as Boolean {
    var problem = problemUi.getProblem();

    if (!_isActivityRunning) {
      if ($.Debug) {
        var problemName = $.getProblemTypeName(problem["typeId"] as Number);
        var elevationText =
          elevation != null ? elevation.format("%.0f") : "n/a";
        $.log(
          Lang.format(
            "Problem '$1$': grayscale=false (activity not running, elevation=$2$).",
            [problemName, elevationText]
          )
        );
      }
      return false;
    }

    if (!_canEvaluateProblemActiveStateAtElevation(problem)) {
      if ($.Debug) {
        var problemName = $.getProblemTypeName(problem["typeId"] as Number);
        $.log(
          Lang.format(
            "Problem '$1$': grayscale=false (no evaluable exposed heights).",
            [problemName]
          )
        );
      }
      return false;
    }

    var shouldRenderGrayscale = !_isProblemActiveAtElevation(
      problem,
      elevation
    );
    if ($.Debug) {
      var problemName = $.getProblemTypeName(problem["typeId"] as Number);
      var elevationText = elevation != null ? elevation.format("%.0f") : "n/a";
      $.log(
        Lang.format("Problem '$1$': grayscale=$2$ (elevation=$3$).", [
          problemName,
          shouldRenderGrayscale ? "true" : "false",
          elevationText,
        ])
      );
    }

    return shouldRenderGrayscale;
  }

  private function _syncScrollingTextCycles() as Void {
    var maxCycle =
      _regionNameScrollingText != null
        ? _regionNameScrollingText.getCycleTicks()
        : 0;

    for (var i = 0; i < _numProblems; i++) {
      if (_problemUis[i] != null) {
        var c = (
          _problemUis[i] as DatafieldProblemUi
        ).getScrollingTextCycleTicks();
        if (c > maxCycle) {
          maxCycle = c;
        }
      }
    }

    if (maxCycle > 0) {
      if (_regionNameScrollingText != null) {
        _regionNameScrollingText.setCycleTicks(maxCycle);
      }
      for (var i = 0; i < _numProblems; i++) {
        if (_problemUis[i] != null) {
          (_problemUis[i] as DatafieldProblemUi).setScrollingTextCycleTicks(
            maxCycle
          );
        }
      }
    }

    // Always reset the tick counter on rebuild so texts start with the initial pause
    AvalancheUi.resetScrollingTexts();
  }

  private function _getHeaderContentHeight(dangerLevel as Number) as Numeric {
    var regionNameFontH = Gfx.getFontHeight(Gfx.FONT_XTINY);
    var headerFontH = Gfx.getFontHeight(Gfx.FONT_MEDIUM);
    var icon =
      Ui.loadResource($.getIconResourceForDangerLevel(dangerLevel)) as
      Ui.BitmapResource;
    var headerLineH = $.max([headerFontH, icon.getHeight()]);

    return regionNameFontH + _getHeaderGapY() + headerLineH;
  }

  private function _getProblemsContentHeight(problemGapY as Number) as Numeric {
    if (_numProblems == 3) {
      // Row 0: problems 0 and 1 side-by-side (height = max of the two)
      var row0H = 0;
      if (_problemUis[0] != null) {
        row0H = (_problemUis[0] as DatafieldProblemUi).getTotalHeight();
      }
      if (_problemUis[1] != null) {
        var h1 = (_problemUis[1] as DatafieldProblemUi).getTotalHeight();
        if (h1 > row0H) {
          row0H = h1;
        }
      }
      // Row 1: problem 2
      var row1H =
        _problemUis[2] != null
          ? (_problemUis[2] as DatafieldProblemUi).getTotalHeight()
          : 0;
      return row0H + problemGapY + row1H;
    }

    var totalH = 0;
    for (var i = 0; i < _numProblems; i++) {
      if (_problemUis[i] != null) {
        totalH += (_problemUis[i] as DatafieldProblemUi).getTotalHeight();
      }
    }
    if (_numProblems > 1) {
      totalH += (_numProblems - 1) * problemGapY;
    }
    return totalH;
  }

  private function _getContentTopY() as Numeric {
    var topPaddingRatio = _isCompactLayout() ? 0.03 : 0.05;
    var topY = (_fieldHeight * topPaddingRatio).toNumber();

    return topY >= 4 ? topY : 4;
  }

  private function _getHeaderGapY() as Numeric {
    var headerGapRatio = _isCompactLayout() ? 0.005 : 0.01;
    var headerGapY = (_fieldHeight * headerGapRatio).toNumber();

    return headerGapY >= 1 ? headerGapY : 1;
  }

  private function _getProblemGapY() as Numeric {
    var isCompact = _isCompactLayout();
    var gapRatio = 0.05;
    var gapReduction = _numProblems == 2 ? 3 : 0;

    if (isCompact && _numProblems < 3) {
      // Compact one-problem and two-problem layouts use a smaller base gap.
      gapRatio = 0.03;
    }

    var problemGapY = (_fieldHeight * gapRatio).toNumber() - gapReduction;

    return problemGapY >= 4 ? problemGapY : 4;
  }

  private function _getFooterPaddingY() as Numeric {
    var footerPaddingRatio = _isCompactLayout() ? 0.025 : 0.04;
    var footerPaddingY = (_fieldHeight * footerPaddingRatio).toNumber();
    if (footerPaddingY < (_isCompactLayout() ? 4 : 2)) {
      footerPaddingY = _isCompactLayout() ? 4 : 2;
    }

    return footerPaddingY;
  }

  private function _getHeaderToProblemsGapY() as Numeric {
    return _isCompactLayout() ? 0 : _getHeaderGapY();
  }

  private function _getUpdatedAtContentHeight() as Numeric {
    if (_updatedAtBitmapH > 0) {
      return _updatedAtBitmapH;
    }

    var fontH = Gfx.getFontHeight(Gfx.FONT_XTINY);
    var updatedIcon =
      Ui.loadResource($.Rez.Drawables.UpdatedIcon) as Ui.BitmapResource;
    return $.max([fontH, updatedIcon.getHeight()]);
  }

  private function _isCompactLayout() as Boolean {
    return _fieldHeight <= 240;
  }

  private function _drawDivider(dc as Gfx.Dc, y as Numeric) as Void {
    var dividerInset = (_fieldWidth * 0.14).toNumber();
    dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(dividerInset, y, _fieldWidth - dividerInset, y);
  }

  private function _drawForecast(dc as Gfx.Dc) as Void {
    if (_noProblemView != null) {
      (_noProblemView as DatafieldNoProblemView).draw(dc);
      return;
    }

    var dangerLevel =
      _detailedWarning != null ? _detailedWarning["dangerLevel"] as Number : 0;
    var dangerColor = $.colorize(dangerLevel);

    // --- Danger level header (top 30%) ---
    var levelText = $.getOrLoadResourceString("Faregrad", :Level);
    var headerText = Lang.format("$1$ $2$", [levelText, dangerLevel]);
    var headerFont = Gfx.FONT_MEDIUM;
    var headerFontH = Gfx.getFontHeight(headerFont);

    var icon =
      Ui.loadResource($.getIconResourceForDangerLevel(dangerLevel)) as
      Ui.BitmapResource;
    var iconW = icon.getWidth();
    var iconH = icon.getHeight();
    var gapX = (_fieldWidth * 0.02).toNumber();

    var textW = dc.getTextWidthInPixels(headerText, headerFont);
    var totalW = textW + gapX + iconW;
    var headerX = (_fieldWidth - totalW) / 2;

    var regionNameFontH = Gfx.getFontHeight(Gfx.FONT_XTINY);
    var headerContentH = _getHeaderContentHeight(dangerLevel);
    var startY = _getContentTopY();
    var headerBottomY = startY + headerContentH;

    if ($.DrawOutlines) {
      $.drawOutline(dc, 0, startY, _fieldWidth, headerContentH);
    }

    _regionNameScrollingText.draw(dc, _regionNameX0, startY);

    var dangerMidY =
      startY + _getHeaderGapY() + regionNameFontH + headerFontH / 2;
    dc.setColor(dangerColor, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      headerX,
      dangerMidY,
      headerFont,
      headerText,
      Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
    );
    dc.drawBitmap(headerX + textW + gapX, dangerMidY - iconH / 2, icon);

    // --- Problems area ---

    var elevation = $.getCurrentElevation();
    var problemGapY = _getProblemGapY();
    var footerH = _getUpdatedAtContentHeight();
    var footerPadding = _getFooterPaddingY();
    var totalProblemsH = _getProblemsContentHeight(problemGapY);
    var headerToProblemsGapY = _getHeaderToProblemsGapY();
    var problemsTopY = headerBottomY + headerToProblemsGapY;
    var problemsBottomY = _fieldHeight - footerPadding - footerH;
    var centeredOffset = (problemsBottomY - problemsTopY - totalProblemsH) / 2;
    if (centeredOffset < 0) {
      centeredOffset = 0;
    }
    var curY = (problemsTopY + centeredOffset).toNumber();

    if (_numProblems == 3) {
      // Row 0: problems 0 and 1 spread outward from center with a small gap
      var centerX = _fieldWidth / 2;
      var inlineGap = (
        _fieldWidth * (_isCompactLayout() ? 0.035 : 0.05)
      ).toNumber();
      var row0H = 0;
      if (_problemUis[0] != null) {
        var p0 = _problemUis[0] as DatafieldProblemUi;
        var p0X = centerX - inlineGap / 2 - p0.getTotalWidth();
        p0.draw(dc, p0X, curY, _shouldRenderProblemInGrayscale(p0, elevation));
        if (p0.getTotalHeight() > row0H) {
          row0H = p0.getTotalHeight();
        }
      }
      if (_problemUis[1] != null) {
        var p1 = _problemUis[1] as DatafieldProblemUi;
        p1.draw(
          dc,
          centerX + inlineGap / 2,
          curY,
          _shouldRenderProblemInGrayscale(p1, elevation)
        );
        if (p1.getTotalHeight() > row0H) {
          row0H = p1.getTotalHeight();
        }
      }
      // Vertical divider at center
      dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
      dc.drawLine(centerX, curY, centerX, curY + row0H);

      curY += row0H;
      _drawDivider(dc, curY + problemGapY / 2);
      curY += problemGapY;

      // Row 1: problem 2 full width
      if (_problemUis[2] != null) {
        var p2 = _problemUis[2] as DatafieldProblemUi;
        p2.draw(
          dc,
          _getCenteredProblemX(p2),
          curY,
          _shouldRenderProblemInGrayscale(p2, elevation)
        );
      }
    } else {
      for (var i = 0; i < _numProblems; i++) {
        if (_problemUis[i] != null) {
          var problemUi = _problemUis[i] as DatafieldProblemUi;
          problemUi.draw(
            dc,
            _getCenteredProblemX(problemUi),
            curY,
            _shouldRenderProblemInGrayscale(problemUi, elevation)
          );
          if (i < _numProblems - 1) {
            _drawDivider(
              dc,
              curY + problemUi.getTotalHeight() + problemGapY / 2
            );
          }
          curY += problemUi.getTotalHeight() + problemGapY;
        }
      }
    }

    _drawUpdatedAt(dc, footerPadding);
  }

  private function _drawUpdatedAt(
    dc as Gfx.Dc,
    footerPadding as Numeric
  ) as Void {
    if (_detailedWarning == null) {
      return;
    }

    if (_updatedAtBitmap == null) {
      var publishedTime = _detailedWarning["published"] as String;
      var publishedMoment = $.parseDate(publishedTime);
      var dateText = $.getHumanReadableDateText(publishedMoment);
      var timestamp = $.getFormattedTimestamp(publishedMoment);
      var text = Lang.format("$1$ $2$", [dateText, timestamp]);

      var font = Gfx.FONT_XTINY;
      var fontH = Gfx.getFontHeight(font);
      var updatedIcon =
        Ui.loadResource($.Rez.Drawables.UpdatedIcon) as Ui.BitmapResource;
      var iconW = updatedIcon.getWidth();
      var iconH = updatedIcon.getHeight();
      var gap = 4;

      var textDimensions = dc.getTextDimensions(text, font);
      _updatedAtBitmapW = iconW + gap + textDimensions[0];
      _updatedAtBitmapH = textDimensions[1] > iconH ? textDimensions[1] : iconH;

      _updatedAtBitmap = $.newBufferedBitmap({
        :width => _updatedAtBitmapW,
        :height => _updatedAtBitmapH,
      });
      var bufferedDc = _updatedAtBitmap.getDc();
      if (bufferedDc has :setAntiAlias) {
        bufferedDc.setAntiAlias(true);
      }
      bufferedDc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      bufferedDc.drawBitmap(0, _updatedAtBitmapH / 2 - iconH / 2, updatedIcon);
      bufferedDc.drawText(
        iconW + gap,
        _updatedAtBitmapH / 2 - fontH / 2,
        font,
        text,
        Gfx.TEXT_JUSTIFY_LEFT
      );
    }

    var bitmapX = (_fieldWidth - _updatedAtBitmapW) / 2;
    var bitmapY = _fieldHeight - footerPadding - _updatedAtBitmapH;
    dc.drawBitmap(bitmapX, bitmapY, _updatedAtBitmap);
  }

  private function _drawCenteredText(dc as Gfx.Dc, text as String) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      _fieldWidth / 2,
      _fieldHeight / 2,
      Gfx.FONT_XTINY,
      text,
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    );
  }

  private function _loadDataFromStorage() as Void {
    _locationDetailedForecast = null;
    _detailedWarning = null;

    var detailedData = $.getDetailedWarningsForLocation();
    if (detailedData != null) {
      _locationDetailedForecast =
        detailedData[0] as DetailedWarningsForLocationResponse;

      // Seed _lastFetchTime from the stored timestamp so we don't refetch
      // immediately if the background already fetched fresh data.
      var storedTime = detailedData[1] as Number;
      if (storedTime > _lastFetchTime) {
        _lastFetchTime = storedTime;
      }

      var warnings =
        _locationDetailedForecast["warnings"] as
        Array<DetailedAvalancheWarning>;
      var idx = $.getDateIndexForDetailedWarnings(warnings, Time.today());
      if (idx >= 0) {
        _detailedWarning = warnings[idx];
      }
    }
  }

  function onDetailedForecastReceived(
    responseCode as Number,
    data as WebRequestDelegateCallbackData
  ) as Void {
    _isLoading = false;

    if (responseCode == 200) {
      if ($.Debug) {
        $.log("Foreground fetch succeeded.");
      }
      _loadDataFromStorage();
      _needsFullRebuild = true;
      Ui.requestUpdate();
    } else if (responseCode == 401) {
      if ($.Debug) {
        $.log(
          "Foreground fetch returned 401 — switching to subscription setup view."
        );
      }

      switchToSubscriptionView();
    } else if ($.Debug) {
      $.log(Lang.format("Foreground fetch failed: $1$", [responseCode]));
    }
  }

  function switchToSubscriptionView() as Void {
    $.setHasSubscription(false);
    var rootView = $.getApp().getRootView();
    if (rootView != null) {
      rootView.showSubscriptionView();
    }
  }
}
