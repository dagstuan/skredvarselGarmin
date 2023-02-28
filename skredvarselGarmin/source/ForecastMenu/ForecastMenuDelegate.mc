import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;

public class ForecastMenuDelegate extends Ui.Menu2InputDelegate {
  private const TIME_TO_SHOW_LOADING = Gregorian.SECONDS_PER_DAY;

  private var _regionId as String?;

  private var _progressBar as Ui.ProgressBar?;
  private var _loadingText as Ui.Resource?;

  //! Constructor
  public function initialize() {
    Menu2InputDelegate.initialize();
  }

  //! Handle an item being selected
  //! @param item The selected menu item
  public function onSelect(item as Ui.CustomMenuItem) as Void {
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

      if (
        data == null ||
        Time.now().compare(new Time.Moment(data[1])) > TIME_TO_SHOW_LOADING
      ) {
        // Data is very stale or non-existent, show loading.
        _loadingText = Ui.loadResource($.Rez.Strings.Loading);
        _progressBar = new Ui.ProgressBar(_loadingText, null);
        Ui.pushView(_progressBar, new ProgressDelegate(), Ui.SLIDE_BLINK);

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
    } else if (_progressBar != null) {
      Ui.switchToView(
        new TextAreaView(
          "Failed to fetch the forecast. Please try again later."
        ),
        new TextAreaViewDelegate(),
        Ui.SLIDE_BLINK
      );

      _progressBar = null;
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

    var view = null;
    var delegate = null;
    var useViewLoop = false;
    if (useViewLoop && Ui has :ViewLoop) {
      // var factory = new DetailedForecastsViewLoopFactory(
      //   regionId,
      //   data,
      //   dataAge
      // );
      // view = new DetailedForecastsViewLoop(factory, startIndex);
      // delegate = new DetailedForecastsViewLoopDelegate(view);
    } else {
      view = new DetailedForecastView(
        regionId,
        startIndex,
        data.size(),
        data[startIndex],
        dataAge,
        true
      );
      delegate = new DetailedForecastViewPageLoopDelegate({
        :index => startIndex,
        :view => view,
        :detailedWarnings => data,
        :regionId => regionId,
        :dataAge => dataAge,
      });
    }

    if (_progressBar != null) {
      Ui.switchToView(view, delegate, Ui.SLIDE_LEFT);
      _progressBar = null;
    } else {
      Ui.pushView(view, delegate, Ui.SLIDE_LEFT);
    }
  }
}
