import Toybox.Lang;

using Toybox.Time;

(:glance)
public class SimpleAvalancheWarning {
  public var dangerLevel as Number;
  public var validFrom as Time.Moment;
  public var validTo as Time.Moment;

  public function initialize(warningData as AvalancheWarningData) {
    dangerLevel = warningData.get("dangerLevel").toNumber();
    validFrom = parseDate(warningData.get("validFrom"));
    validTo = parseDate(warningData.get("validTo"));
  }
}
