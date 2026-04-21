import { defaultNS, resources } from "./i18n/resources";

declare module "i18next" {
  interface CustomTypeOptions {
    defaultNS: typeof defaultNS;
    resources: (typeof resources)["en"];
    enableSelector: true;
  }
}