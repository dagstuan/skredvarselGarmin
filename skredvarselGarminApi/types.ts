export type VarsomAvalancheWarning = {
  RegId: number;
  RegionId: number;
  RegionName: string;
  RegionTypeId: number;
  RegionTypeName: string;
  DangerLevel: string;
  ValidFrom: Date;
  ValidTo: Date;
  NextWarningTime: Date;
  PublishTime: Date;
  DangerIncreaseTime?: any;
  DangerDecreaseTime?: any;
  MainText: string;
  LangKey: number;
};

export type VarsomRegionSummary = {
  Id: number;
  Name: string;
  TypeId: number;
  TypeName: string;
  AvalancheWarningList: VarsomAvalancheWarning[];
};

export type AvalancheWarning = {
  dangerLevel: VarsomAvalancheWarning["DangerLevel"];
  validFrom: VarsomAvalancheWarning["ValidFrom"];
  validTo: VarsomAvalancheWarning["ValidTo"];
  mainText: VarsomAvalancheWarning["MainText"];
};

export type RegionSummary = {
  id: VarsomRegionSummary["Id"];
  name: VarsomRegionSummary["Name"];
  avalancheWarningList: AvalancheWarning[];
};
