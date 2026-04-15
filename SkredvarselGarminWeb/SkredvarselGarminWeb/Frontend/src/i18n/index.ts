import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import {
  defaultNS,
  resources,
  supportedLanguages,
  type AppLanguage,
} from "./resources";

const storageKey = "skredvarsel.language";

const isSupportedLanguage = (language: string | null | undefined): language is AppLanguage =>
  language === "no" || language === "en" || language === "sv";

const normalizeLanguage = (language: string | null | undefined): AppLanguage => {
  if (language?.toLowerCase().startsWith("en")) {
    return "en";
  }

  if (language?.toLowerCase().startsWith("sv")) {
    return "sv";
  }

  return "no";
};

const getInitialLanguage = (): AppLanguage => {
  if (typeof window === "undefined") {
    return "no";
  }

  const storedLanguage = window.localStorage.getItem(storageKey);
  if (isSupportedLanguage(storedLanguage)) {
    return storedLanguage;
  }

  return normalizeLanguage(window.navigator.language);
};

const updateDocumentLanguage = (language: string) => {
  if (typeof document === "undefined") {
    return;
  }

  document.documentElement.lang = normalizeLanguage(language);
};

void i18n.use(initReactI18next).init({
  resources,
  defaultNS,
  ns: [defaultNS],
  lng: getInitialLanguage(),
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

updateDocumentLanguage(i18n.resolvedLanguage ?? i18n.language);

i18n.on("languageChanged", (language) => {
  if (typeof window !== "undefined") {
    window.localStorage.setItem(storageKey, normalizeLanguage(language));
  }

  updateDocumentLanguage(language);
});

export default i18n;