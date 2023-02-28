// import Toybox.Lang;

// using Toybox.WatchUi as Ui;

// class DetailedForecastsViewLoopFactory extends Ui.ViewLoopFactory {
//   private var _regionId as String;
//   private var _detailedWarnings as Array<DetailedAvalancheWarning>;
//   private var _dataAge as Number;

//   public function initialize(
//     regionId as String,
//     detailedWarnings as Array<DetailedAvalancheWarning>,
//     dataAge as Number
//   ) {
//     ViewLoopFactory.initialize();

//     _regionId = regionId;
//     _detailedWarnings = detailedWarnings;
//     _dataAge = dataAge;
//   }

//   public function getSize() as Number {
//     return _detailedWarnings.size();
//   }

//   public function getView(
//     page as Lang.Number
//   ) as Lang.Array<Ui.View or Ui.BehaviorDelegate>? {
//     var view = new DetailedForecastView(
//       _regionId,
//       page,
//       getSize(),
//       _detailedWarnings[page],
//       _dataAge,
//       false
//     );
//     var delegate = new DetailedForecastViewDelegate({
//       :view => view,
//       :regionId => _regionId,
//     });

//     return [view, delegate];
//   }
// }
