import Toybox.Lang;

using Toybox.Time;

(:glance)
public class AvalancheWarning {
  public var dangerLevel as String;
  public var validFrom as Time.Moment;
  public var validTo as Time.Moment;
  public var mainText as String;

  public function initialize(warningData as AvalancheWarningData) {
    dangerLevel = warningData.get("dangerLevel");
    validFrom = parseDate(warningData.get("validFrom"));
    validTo = parseDate(warningData.get("validTo"));
    mainText = warningData.get("mainText");
  }
}
