import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian;

public class ForecastMenuInputDelegate extends Ui.Menu2InputDelegate {
  private const TIME_TO_SHOW_LOADING = Gregorian.SECONDS_PER_DAY;
  private var _detailedForecastApi as DetailedForecastApi;

  private var _regionId as String?;

  private var _progressBar as Ui.ProgressBar?;
  private var _loadingText as Ui.Resource?;

  //! Constructor
  public function initialize(detailedForecastApi as DetailedForecastApi) {
    Menu2InputDelegate.initialize();

    _detailedForecastApi = detailedForecastApi;
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

      var data = _detailedForecastApi.getDetailedWarningsForRegion(_regionId);
      if (
        data == null ||
        Time.now().compare(new Time.Moment(data[1])) > TIME_TO_SHOW_LOADING
      ) {
        // Data is very stale or non-existent, show loading.
        _loadingText = Ui.loadResource($.Rez.Strings.Loading);
        _progressBar = new Ui.ProgressBar(_loadingText, null);
        Ui.pushView(_progressBar, new ProgressDelegate(), Ui.SLIDE_BLINK);

        _detailedForecastApi.loadDetailedWarningsForRegion(
          _regionId,
          method(:onReceive)
        );
      } else {
        var warnings = data[0];
        var fetchedTime = data[1];

        var dataAge = Time.now().compare(new Time.Moment(fetchedTime));

        pushDetailedForecastView(_regionId, 2, data[0], dataAge);
      }
    }

    WatchUi.requestUpdate();
  }

  public function onReceive(data as WebRequestCallbackData) as Void {
    if (data != null) {
      pushDetailedForecastView(
        _regionId,
        2,
        data as Array<DetailedAvalancheWarning>,
        0
      );
    } else if (_progressBar != null) {
      Ui.popView(Ui.SLIDE_BLINK);
      _progressBar = null;
    }
  }

  private function pushDetailedForecastView(
    regionId as String,
    index as Number,
    data as Array<DetailedAvalancheWarning>,
    dataAge as Number
  ) {
    var view = new DetailedForecastView(
      _detailedForecastApi,
      regionId,
      index,
      data.size(),
      data[index],
      dataAge
    );
    var delegate = new DetailedForecastViewDelegate({
      :detailedForecastApi => _detailedForecastApi,
      :index => index,
      :view => view,
      :detailedWarnings => data,
      :regionId => regionId,
      :dataAge => dataAge,
    });

    if (_progressBar != null) {
      Ui.switchToView(view, delegate, Ui.SLIDE_LEFT);
      _progressBar = null;
    } else {
      Ui.pushView(view, delegate, Ui.SLIDE_LEFT);
    }
  }
}
