import Toybox.Lang;

function getSortedSwedishRegionIds() as Array<String> {
  return [
    "se_15",
    "se_16",
    "se_17",
    "se_11",
    "se_18",
    "se_19",
    "se_12",
    "se_14",
    "se_20",
    "se_21",
    "se_22",
    "se_23",
  ];
}

(:glance)
function getSwedishRegionName(regionId as String) as String {
  var numericId = regionId.substring(3, regionId.length()).toNumber();

  if (numericId == 15) {
    return "Abisko/Riksgränsfjällen Väst";
  } else if (numericId == 16) {
    return "Abisko/Riksgränsfjällen Öst";
  } else if (numericId == 17) {
    return "Kebnekaisefjällen Väst";
  } else if (numericId == 11) {
    return "Kebnekaisefjällen Öst";
  } else if (numericId == 18) {
    return "Västra Vindelfjällen Väst";
  } else if (numericId == 19) {
    return "Västra Vindelfjällen Öst";
  } else if (numericId == 12) {
    return "Södra Jämtlandsfjällen Väst";
  } else if (numericId == 14) {
    return "Södra Jämtlandsfjällen Öst";
  } else if (numericId == 20) {
    return "Södra Lapplandsfjällen Nord";
  } else if (numericId == 21) {
    return "Södra Lapplandsfjällen Syd";
  } else if (numericId == 22) {
    return "Västra Härjedalsfjällen Nordväst";
  } else if (numericId == 23) {
    return "Västra Härjedalsfjällen Sydöst";
  }

  return regionId;
}
