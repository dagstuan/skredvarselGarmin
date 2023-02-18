import Toybox.Lang;

using Toybox.Time;

public class DetailedAvalancheWarning {
  public var dangerLevel as Number;
  public var validFrom as Time.Moment;
  public var validTo as Time.Moment;
  public var mainText as String;
  public var avalancheProblems as Array<AvalancheProblem>;

  public function initialize(warningData as AvalancheWarningData) {
    dangerLevel = warningData.get("dangerLevel").toNumber();
    validFrom = parseDate(warningData.get("validFrom"));
    validTo = parseDate(warningData.get("validTo"));
    mainText = warningData.get("mainText");

    var avalancheProblemsData = warningData.get("avalancheProblems") as Array;
    var numAvalancheProblems = avalancheProblemsData.size();

    avalancheProblems = new [numAvalancheProblems];

    for (var i = 0; i < numAvalancheProblems; i++) {
      avalancheProblems[i] = new AvalancheProblem(avalancheProblemsData[i]);
    }
  }
}
