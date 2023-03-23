import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;

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

        var dataAge = Time.now().compare(new Time.Moment(fetchedTime));

        pushDetailedForecastView(_regionId, warnings, dataAge);
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
        0
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
    dataAge as Number
  ) {
    // TODO: Make this cleaner.
    var startIndex = 2;

    var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if (now.hour >= 17) {
      startIndex = 3;
    }

    var view = new DetailedForecastView(
      regionId,
      startIndex,
      data.size(),
      data[startIndex],
      true
    );
    var delegate = new DetailedForecastViewPageLoopDelegate({
      :index => startIndex,
      :view => view,
      :detailedWarnings => data,
      :regionId => regionId,
      :dataAge => dataAge,
    });

    if (_loadingView != null) {
      Ui.switchToView(view, delegate, Ui.SLIDE_LEFT);
      _loadingView = null;
    } else {
      Ui.pushView(view, delegate, Ui.SLIDE_LEFT);
    }
  }
}
