import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useCurrentLanguage } from "../routes";

export const useSyncLanguageWithRoute = () => {
  const { i18n } = useTranslation();
  const routeLanguage = useCurrentLanguage();

  useEffect(() => {
    if (i18n.resolvedLanguage !== routeLanguage) {
      void i18n.changeLanguage(routeLanguage);
    }
  }, [i18n, routeLanguage]);
};