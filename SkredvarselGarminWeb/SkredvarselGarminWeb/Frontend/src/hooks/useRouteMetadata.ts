import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useCurrentLanguage, useCurrentRouteKey, type AppRouteKey } from "../routes";

const seoSelectors: Record<
  AppRouteKey,
  {
    title: (resources: typeof import("../i18n/resources").resources["en"]["translation"]) => string;
    description: (resources: typeof import("../i18n/resources").resources["en"]["translation"]) => string;
  }
> = {
  home: {
    title: ($) => $.seo.home.title,
    description: ($) => $.seo.home.description,
  },
  account: {
    title: ($) => $.seo.account.title,
    description: ($) => $.seo.account.description,
  },
  subscribe: {
    title: ($) => $.seo.subscribe.title,
    description: ($) => $.seo.subscribe.description,
  },
  addWatch: {
    title: ($) => $.seo.addWatch.title,
    description: ($) => $.seo.addWatch.description,
  },
  login: {
    title: ($) => $.seo.login.title,
    description: ($) => $.seo.login.description,
  },
  faq: {
    title: ($) => $.seo.faq.title,
    description: ($) => $.seo.faq.description,
  },
  salesConditions: {
    title: ($) => $.seo.salesConditions.title,
    description: ($) => $.seo.salesConditions.description,
  },
  privacy: {
    title: ($) => $.seo.privacy.title,
    description: ($) => $.seo.privacy.description,
  },
  admin: {
    title: ($) => $.seo.admin.title,
    description: ($) => $.seo.admin.description,
  },
};

const localeCodes = {
  no: "no_NB",
  en: "en_US",
  sv: "sv_SE",
} as const;

const ensureMetaTag = (attribute: "name" | "property", value: string) => {
  const selector = `meta[${attribute}="${value}"]`;
  let meta = document.head.querySelector(selector) as HTMLMetaElement | null;

  if (!meta) {
    meta = document.createElement("meta");
    meta.setAttribute(attribute, value);
    document.head.appendChild(meta);
  }

  return meta;
};

export const useRouteMetadata = () => {
  const { t } = useTranslation();
  const routeKey = useCurrentRouteKey();
  const language = useCurrentLanguage();
  const location = useLocation();

  const selectors = seoSelectors[routeKey];
  const title = t(selectors.title);
  const description = t(selectors.description);

  useEffect(() => {
    document.title = title;

    ensureMetaTag("name", "description").content = description;
    ensureMetaTag("property", "og:title").content = title;
    ensureMetaTag("property", "og:description").content = description;
    ensureMetaTag("property", "og:locale").content = localeCodes[language];
    ensureMetaTag("property", "og:url").content = window.location.href;
    ensureMetaTag("name", "twitter:title").content = title;
    ensureMetaTag("name", "twitter:description").content = description;
  }, [description, language, location.hash, location.pathname, location.search, title]);
};