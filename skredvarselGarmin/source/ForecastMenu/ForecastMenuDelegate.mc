import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;

public function getStartDateForDetailedWarnings() {
  var startDate = Time.today();
  var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
  if (now.hour >= 17) {
    startDate = startDate.add(new Time.Duration(Gregorian.SECONDS_PER_DAY));
  }
  return startDate;
}

public class ForecastMenuDelegate extends Ui.Menu2InputDelegate {
  private var _regionId as String?;

  private var _loadingView as LoadingView?;

  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  public function onSelect(item as Ui.MenuItem) as Void {
    var id = item.getId();

    if (id.equals("edit")) {
      WatchUi.pushView(
        new EditMenu(),
        new EditMenuDelegate(),
        WatchUi.SLIDE_LEFT
      );
    } else {
      _regionId = (item as ForecastMenuItem).getRegionId();

      var data = $.getDetailedWarningsForRegion(_regionId);

      if (data == null || $.getStorageDataAge(data) > $.TIME_TO_SHOW_LOADING) {
        // Data is very stale or non-existent, show loading.

        _loadingView = new LoadingView();
        Ui.pushView(_loadingView, new LoadingViewDelegate(), Ui.SLIDE_BLINK);

        $.loadDetailedWarningsForRegion(_regionId, method(:onReceive));
      } else {
        var warnings = data[0];
        var fetchedTime = data[1];

        pushDetailedForecastView(
          _regionId,
          warnings,
          new Time.Moment(fetchedTime)
        );
      }
    }

    WatchUi.requestUpdate();
  }

  public function onReceive(
    responseCode as Number,
    data as WebRequestCallbackData
  ) as Void {
    if (responseCode == 200 && data != null) {
      pushDetailedForecastView(
        _regionId,
        data as Array<DetailedAvalancheWarning>,
        Time.now()
      );
    } else if (_loadingView != null) {
      Ui.switchToView(
        new TextAreaView(
          $.getOrLoadResourceString(
            "Fikk ikke til å hente varselet. Prøv å koble til telefonen på nytt.",
            :FailedToFetchTheForecast
          )
        ),
        new TextAreaViewDelegate(),
        Ui.SLIDE_BLINK
      );

      _loadingView = null;
    }
  }

  private function pushDetailedForecastView(
    regionId as String,
    data as Array<DetailedAvalancheWarning>,
    fetchedTime as Time.Moment
  ) {
    var startDate = $.getStartDateForDetailedWarnings();
    var startIndex = $.getDateIndexForDetailedWarnings(data, startDate);

    if (startIndex == -1) {
      startIndex = 0;
      startDate = $.parseDate(data[startIndex]["validity"][0]);
    }

    var view = new DetailedForecastView({
      :regionId => regionId,
      :index => startIndex,
      :numWarnings => data.size(),
      :warning => data[startIndex],
      :fetchedTime => fetchedTime,
    });
    var delegate = new DetailedForecastViewPageLoopDelegate({
      :visibleDate => startDate,
      :view => view,
      :detailedWarnings => data,
      :regionId => regionId,
      :fetchedTime => fetchedTime,
    });

    if (_loadingView != null) {
      Ui.switchToView(view, delegate, Ui.SLIDE_LEFT);
      _loadingView = null;
    } else {
      Ui.pushView(view, delegate, Ui.SLIDE_LEFT);
    }
  }
}
