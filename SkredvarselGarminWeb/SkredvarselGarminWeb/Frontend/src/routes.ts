import { useCallback } from "react";
import { useLocation, useMatches } from "react-router-dom";
import { type AppLanguage } from "./i18n/resources";

export const defaultLanguage: AppLanguage = "no";

export const appRouteKeys = [
  "home",
  "account",
  "subscribe",
  "addWatch",
  "login",
  "faq",
  "salesConditions",
  "privacy",
  "admin",
] as const;

export type AppRouteKey = (typeof appRouteKeys)[number];

export type AppRouteHandle = {
  routeKey: AppRouteKey;
};

export const routeSegments: Record<AppRouteKey, Record<AppLanguage, string>> = {
  home: {
    no: "/",
    en: "/en",
    sv: "/sv",
  },
  account: {
    no: "account",
    en: "account",
    sv: "konto",
  },
  subscribe: {
    no: "subscribe",
    en: "buy-subscription",
    sv: "kop-abonnemang",
  },
  addWatch: {
    no: "addwatch",
    en: "add-watch",
    sv: "lagg-till-klocka",
  },
  login: {
    no: "login",
    en: "login",
    sv: "logga-in",
  },
  faq: {
    no: "faq",
    en: "faq",
    sv: "fragor-och-svar",
  },
  salesConditions: {
    no: "salesconditions",
    en: "terms",
    sv: "kopvillkor",
  },
  privacy: {
    no: "privacy",
    en: "privacy",
    sv: "integritet",
  },
  admin: {
    no: "admin",
    en: "admin",
    sv: "admin",
  },
};

const localePrefixes: Record<AppLanguage, string> = {
  no: "",
  en: "/en",
  sv: "/sv",
};

type UrlState = {
  search?: string;
  hash?: string;
};

const normalizeSearch = (search?: string) => {
  if (!search) {
    return "";
  }

  return search.startsWith("?") ? search : `?${search}`;
};

const normalizeHash = (hash?: string) => {
  if (!hash) {
    return "";
  }

  return hash.startsWith("#") ? hash : `#${hash}`;
};

export const buildLocalizedPath = (
  language: AppLanguage,
  routeKey: AppRouteKey,
  state?: UrlState,
) => {
  const path =
    routeKey === "home"
      ? routeSegments.home[language]
      : `${localePrefixes[language]}/${routeSegments[routeKey][language]}`;

  return `${path}${normalizeSearch(state?.search)}${normalizeHash(state?.hash)}`;
};

export const getLanguageFromPathname = (pathname: string): AppLanguage => {
  if (pathname === "/en" || pathname.startsWith("/en/")) {
    return "en";
  }

  if (pathname === "/sv" || pathname.startsWith("/sv/")) {
    return "sv";
  }

  return defaultLanguage;
};

export const useCurrentLanguage = () => {
  const location = useLocation();

  return getLanguageFromPathname(location.pathname);
};

export const useCurrentRouteKey = () => {
  const matches = useMatches();

  for (let index = matches.length - 1; index >= 0; index -= 1) {
    const handle = matches[index].handle as AppRouteHandle | undefined;

    if (handle?.routeKey) {
      return handle.routeKey;
    }
  }

  return "home" satisfies AppRouteKey;
};

export const usePathForCurrentLanguage = () => {
  const language = useCurrentLanguage();

  return useCallback(
    (routeKey: AppRouteKey, state?: UrlState) =>
      buildLocalizedPath(language, routeKey, state),
    [language],
  );
};