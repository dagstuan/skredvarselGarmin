// import Toybox.Lang;

// using Toybox.WatchUi as Ui;
// using Toybox.Time as Time;
// using Toybox.Time.Gregorian;

// class DetailedForecastsLoadingView extends Ui.View {
//   private const TIME_TO_CONSIDER_STALE = Gregorian.SECONDS_PER_HOUR * 2;
//   private const TIME_TO_SHOW_LOADING = Gregorian.SECONDS_PER_DAY;

//   private var _detailedForecastApi as DetailedForecastApi;
//   private var _regionId as String;

//   private var _warnings as Array<DetailedAvalancheWarning>?;
//   private var _warningsFetchedTime as Time.Moment?;

//   private var _progressBar as Ui.ProgressBar?;

//   public function initialize(
//     detailedForecastApi as DetailedForecastApi,
//     regionId as String
//   ) {
//     View.initialize();

//     _detailedForecastApi = detailedForecastApi;
//     _regionId = regionId;
//   }

//   public function onShow() {
//     getWarningsFromCache();
//     if (
//       _warnings == null ||
//       Time.now().compare(_warningsFetchedTime) > TIME_TO_SHOW_LOADING
//     ) {
//       // Har ikke warning. Vis loading.
//       _loadingText = Ui.loadResource($.Rez.Strings.Loading);
//       _progressBar = new Ui.ProgressBar(_loadingText, null);
//       Ui.pushView(
//         _progressBar,
//         new DetailedWarningsProgressDelegate(),
//         Ui.SLIDE_BLINK
//       );

//       _detailedForecastApi.loadDetailedWarningsForRegion(
//         _regionId,
//         method(:onReceive)
//       );
//     } else if (
//       Time.now().compare(_warningsFetchedTime) > TIME_TO_CONSIDER_STALE
//     ) {
//       $.logMessage("Stale forecast, try to reload in background");

//       _detailedForecastApi.loadDetailedWarningsForRegion(
//         _regionId,
//         method(:onReceive)
//       );

//       // Har warning, men den er stale. Vis bildet og last i bakgrunnen.
//     }
//   }

//   public function onHide() {
//     _loadingText = null;
//   }

//   private function getWarningsFromCache() as Void {
//     var data = _detailedForecastApi.getDetailedWarningsForRegion(_regionId);

//     if (data != null) {
//       _warnings = data[0];
//       _warningsFetchedTime = new Time.Moment(data[1]);
//     }
//   }

//   public function onReceive(data as WebRequestCallbackData) as Void {
//     if (_progressBar != null) {
//       Ui.popView(Ui.SLIDE_BLINK);
//     }

//     if (data != null) {
//       getWarningsFromCache();
//       Ui.requestUpdate();
//     }
//   }
// }
