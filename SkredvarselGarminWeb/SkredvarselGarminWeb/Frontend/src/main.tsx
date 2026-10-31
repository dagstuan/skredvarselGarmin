import "./i18n";
import "./index.css";
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createBrowserRouter,
  Navigate,
  type RouteObject,
  RouterProvider,
} from "react-router-dom";
import App from "./App";
import ErrorPage from "./Components/ErrorPage";
import { LanguageProvider } from "./Components/LanguageProvider";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { Toaster } from "./Components/ui/toast";
import { useTranslation } from "react-i18next";
import { supportedLanguages, type AppLanguage } from "./i18n/resources";
import {
  buildLocalizedPath,
  languagePrefixes,
  routeSegments,
  type AppRouteHandle,
} from "./routes";

// Remove facebook oauth redirect hash.
if (window.location.hash === "#_=_") {
  history.replaceState
    ? history.replaceState(null, "", window.location.href.split("#")[0])
    : (window.location.hash = "");
}

export const queryClient = new QueryClient();

const HydrateFallback = () => {
  const { t } = useTranslation();

  return (
    <div className="flex min-h-[40vh] items-center justify-center p-6 text-sm text-muted-foreground">
      {t(($) => $.common.loading)}
    </div>
  );
};

const hydrateFallbackElement = <HydrateFallback />;

const routeHandle = (routeKey: AppRouteHandle["routeKey"]): AppRouteHandle => ({
  routeKey,
});

const modalRoutes = {
  account: () => import("./Pages/AccountPage"),
  subscribe: () => import("./Pages/BuySubscriptionModalPage"),
  addWatch: () => import("./Pages/AddWatchModalPage"),
  login: () => import("./Pages/LoginModalPage"),
};

const pageRoutes = {
  faq: () => import("./Pages/FaqPage"),
  salesConditions: () => import("./Pages/SalesConditionsPage"),
  privacy: () => import("./Pages/PrivacyPolicyPage"),
  admin: () => import("./Pages/AdminPage"),
};

const keysOf = <T extends object>(object: T) =>
  Object.keys(object) as (keyof T)[];

// The same routes for every language, under the language's prefix.
const createLanguageRoutes = (language: AppLanguage): RouteObject[] => {
  const prefix = languagePrefixes[language];

  return [
    {
      handle: routeHandle("home"),
      hydrateFallbackElement,
      path: prefix || "/",
      lazy: () => import("./Pages/FrontPage"),
      // Modals render on top of the front page.
      children: keysOf(modalRoutes).map((routeKey) => ({
        handle: routeHandle(routeKey),
        hydrateFallbackElement,
        path: routeSegments[routeKey],
        lazy: modalRoutes[routeKey],
      })),
    },
    ...keysOf(pageRoutes).map((routeKey) => ({
      handle: routeHandle(routeKey),
      hydrateFallbackElement,
      path: `${prefix}/${routeSegments[routeKey]}`,
      lazy: pageRoutes[routeKey],
    })),
  ];
};

// Old Norwegian paths that may still be linked to.
const legacyRedirects: RouteObject[] = [
  {
    path: "/minSide",
    element: <Navigate to={buildLocalizedPath("no", "account")} replace />,
  },
  {
    path: "/salgsbetingelser",
    element: (
      <Navigate to={buildLocalizedPath("no", "salesConditions")} replace />
    ),
  },
  {
    path: "/personvern",
    element: <Navigate to={buildLocalizedPath("no", "privacy")} replace />,
  },
];

const router = createBrowserRouter([
  {
    element: (
      <LanguageProvider>
        <App />
      </LanguageProvider>
    ),
    errorElement: (
      <LanguageProvider>
        <ErrorPage />
      </LanguageProvider>
    ),
    children: [
      ...supportedLanguages.flatMap(createLanguageRoutes),
      ...legacyRedirects,
    ],
  },
]);

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <Toaster>
        <RouterProvider router={router} />
        <ReactQueryDevtools initialIsOpen={false} />
      </Toaster>
    </QueryClientProvider>
  </React.StrictMode>,
);
