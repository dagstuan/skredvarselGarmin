import { useEffect, type ReactNode } from "react";
import { I18nextProvider } from "react-i18next";
import { i18nInstances } from "../i18n/index";
import { useCurrentLanguage } from "../routes";

// Provides the i18next instance for the language in the URL.
export const LanguageProvider = ({ children }: { children: ReactNode }) => {
  const language = useCurrentLanguage();

  // React can't render attributes on <html>, so this has to be an effect.
  useEffect(() => {
    document.documentElement.lang = language;
  }, [language]);

  return (
    <I18nextProvider i18n={i18nInstances[language]}>{children}</I18nextProvider>
  );
};
