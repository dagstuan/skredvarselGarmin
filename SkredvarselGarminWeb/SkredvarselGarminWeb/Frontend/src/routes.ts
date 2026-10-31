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

// Path segments are the same in every language; only the prefix differs.
export const routeSegments: Record<Exclude<AppRouteKey, "home">, string> = {
  account: "account",
  subscribe: "subscribe",
  addWatch: "addwatch",
  login: "login",
  faq: "faq",
  salesConditions: "salesconditions",
  privacy: "privacy",
  admin: "admin",
};

export const languagePrefixes: Record<AppLanguage, string> = {
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
  const prefix = languagePrefixes[language];
  const path =
    routeKey === "home"
      ? prefix || "/"
      : `${prefix}/${routeSegments[routeKey]}`;

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

// Link to a backend endpoint that redirects back to the frontend. The language
// is passed along so the backend can redirect to the localized route.
export const buildBackendUrl = (
  path: string,
  language: AppLanguage,
  params: Record<string, string | null | undefined> = {},
) => {
  const searchParams = new URLSearchParams();

  for (const [key, value] of Object.entries(params)) {
    if (value) {
      searchParams.set(key, value);
    }
  }

  if (language !== defaultLanguage) {
    searchParams.set("lang", language);
  }

  const search = searchParams.toString();

  return search ? `${path}?${search}` : path;
};

export const usePathForCurrentLanguage = () => {
  const language = useCurrentLanguage();

  return useCallback(
    (routeKey: AppRouteKey, state?: UrlState) =>
      buildLocalizedPath(language, routeKey, state),
    [language],
  );
};
