import {
  AvalancheWarning,
  VarsomAvalancheWarning,
  VarsomRegionSummary,
} from "./types";

export const mapToRegionSummary = (
  varsomRegionSummary: VarsomRegionSummary
) => ({
  id: varsomRegionSummary.Id,
  name: varsomRegionSummary.Name,
  avalancheWarningList:
    varsomRegionSummary.AvalancheWarningList.map(mapToAvalanceWarning),
});

export const mapToAvalanceWarning = (
  varsomAvalanceWarning: VarsomAvalancheWarning
): AvalancheWarning => ({
  dangerLevel: varsomAvalanceWarning.DangerLevel,
  validFrom: varsomAvalanceWarning.ValidFrom,
  validTo: varsomAvalanceWarning.ValidTo,
  mainText: varsomAvalanceWarning.MainText,
});
