import Toybox.Lang;

using Toybox.Time;

public class AvalancheProblem {
  public var avalancheProblemTypeId as Number;
  public var avalancheProblemTypeName as String;
  public var exposedHeight1 as Number;
  public var exposedHeight2 as Number;
  public var exposedHeightFill as Number;
  public var validExpositions as String;

  public function initialize(warningData as AvalancheWarningData) {
    avalancheProblemTypeId = warningData
      .get("avalancheProblemTypeId")
      .toNumber();
    avalancheProblemTypeName = warningData.get("avalancheProblemTypeName");
    exposedHeight1 = warningData.get("exposedHeight1").toNumber();
    exposedHeight2 = warningData.get("exposedHeight2").toNumber();
    exposedHeightFill = warningData.get("exposedHeightFill").toNumber();
    validExpositions = warningData.get("validExpositions");
  }
}
