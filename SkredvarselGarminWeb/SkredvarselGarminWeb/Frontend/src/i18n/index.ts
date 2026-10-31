import i18n, { type i18n as I18n } from "i18next";
import { initReactI18next } from "react-i18next";
import {
  defaultNS,
  resources,
  supportedLanguages,
  type AppLanguage,
} from "./resources";

void i18n.use(initReactI18next).init({
  resources,
  defaultNS,
  ns: [defaultNS],
  lng: "no",
  fallbackLng: "no",
  supportedLngs: [...supportedLanguages],
  interpolation: {
    escapeValue: false,
  },
  react: {
    useSuspense: false,
  },
  returnNull: false,
});

// One instance per language, sharing the loaded resources. LanguageProvider
// picks one from the URL during render, so there's no global language to keep
// in sync with the router.
export const i18nInstances = Object.fromEntries(
  supportedLanguages.map((language) => [
    language,
    i18n.cloneInstance({ lng: language }),
  ]),
) as Record<AppLanguage, I18n>;
