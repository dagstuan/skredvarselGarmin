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
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { Toaster } from "./Components/ui/toast";
import { useTranslation } from "react-i18next";
import { type AppLanguage } from "./i18n/resources";
import {
  buildLocalizedPath,
  defaultLanguage,
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

const createModalChildren = (language: AppLanguage): RouteObject[] => {
  const routes: RouteObject[] = [
    {
      handle: routeHandle("account"),
      hydrateFallbackElement,
      path: routeSegments.account[language],
      lazy: () => import("./Pages/AccountPage"),
    },
    {
      path: language === defaultLanguage ? "minSide" : "konto",
      element: <Navigate to={buildLocalizedPath(language, "account")} replace />,
    },
    {
      handle: routeHandle("subscribe"),
      hydrateFallbackElement,
      path: routeSegments.subscribe[language],
      lazy: () => import("./Pages/BuySubscriptionModalPage"),
    },
    {
      handle: routeHandle("addWatch"),
      hydrateFallbackElement,
      path: routeSegments.addWatch[language],
      lazy: () => import("./Pages/AddWatchModalPage"),
    },
    {
      handle: routeHandle("login"),
      hydrateFallbackElement,
      path: routeSegments.login[language],
      lazy: () => import("./Pages/LoginModalPage"),
    },
  ];

  if (language === "en") {
    routes.push(
      {
        path: "subscribe",
        element: <Navigate to={buildLocalizedPath(language, "subscribe")} replace />,
      },
      {
        path: "addwatch",
        element: <Navigate to={buildLocalizedPath(language, "addWatch")} replace />,
      },
    );
  }

  return routes;
};

const router = createBrowserRouter([
  {
    element: <App />,
    errorElement: <ErrorPage />,
    children: [
      {
        handle: routeHandle("home"),
        hydrateFallbackElement,
        path: routeSegments.home.no,
        lazy: () => import("./Pages/FrontPage"),
        children: createModalChildren("no"),
      },
      {
        handle: routeHandle("home"),
        hydrateFallbackElement,
        path: routeSegments.home.en,
        lazy: () => import("./Pages/FrontPage"),
        children: createModalChildren("en"),
      },
      {
        handle: routeHandle("home"),
        hydrateFallbackElement,
        path: routeSegments.home.sv,
        lazy: () => import("./Pages/FrontPage"),
        children: createModalChildren("sv"),
      },
      {
        handle: routeHandle("faq"),
        hydrateFallbackElement,
        path: routeSegments.faq.no,
        lazy: () => import("./Pages/FaqPage"),
      },
      {
        handle: routeHandle("faq"),
        hydrateFallbackElement,
        path: buildLocalizedPath("en", "faq").slice(1),
        lazy: () => import("./Pages/FaqPage"),
      },
      {
        handle: routeHandle("faq"),
        hydrateFallbackElement,
        path: buildLocalizedPath("sv", "faq").slice(1),
        lazy: () => import("./Pages/FaqPage"),
      },
      {
        path: "salgsbetingelser",
        element: <Navigate to={buildLocalizedPath("no", "salesConditions")} replace />,
      },
      {
        handle: routeHandle("salesConditions"),
        hydrateFallbackElement,
        path: routeSegments.salesConditions.no,
        lazy: () => import("./Pages/SalesConditionsPage"),
      },
      {
        path: "en/salesconditions",
        element: <Navigate to={buildLocalizedPath("en", "salesConditions")} replace />,
      },
      {
        handle: routeHandle("salesConditions"),
        hydrateFallbackElement,
        path: buildLocalizedPath("en", "salesConditions").slice(1),
        lazy: () => import("./Pages/SalesConditionsPage"),
      },
      {
        handle: routeHandle("salesConditions"),
        hydrateFallbackElement,
        path: buildLocalizedPath("sv", "salesConditions").slice(1),
        lazy: () => import("./Pages/SalesConditionsPage"),
      },
      {
        path: "personvern",
        element: <Navigate to={buildLocalizedPath("no", "privacy")} replace />,
      },
      {
        handle: routeHandle("privacy"),
        hydrateFallbackElement,
        path: routeSegments.privacy.no,
        lazy: () => import("./Pages/PrivacyPolicyPage"),
      },
      {
        handle: routeHandle("privacy"),
        hydrateFallbackElement,
        path: buildLocalizedPath("en", "privacy").slice(1),
        lazy: () => import("./Pages/PrivacyPolicyPage"),
      },
      {
        handle: routeHandle("privacy"),
        hydrateFallbackElement,
        path: buildLocalizedPath("sv", "privacy").slice(1),
        lazy: () => import("./Pages/PrivacyPolicyPage"),
      },
      {
        handle: routeHandle("admin"),
        hydrateFallbackElement,
        path: routeSegments.admin.no,
        lazy: () => import("./Pages/AdminPage"),
      },
      {
        handle: routeHandle("admin"),
        hydrateFallbackElement,
        path: buildLocalizedPath("en", "admin").slice(1),
        lazy: () => import("./Pages/AdminPage"),
      },
      {
        handle: routeHandle("admin"),
        hydrateFallbackElement,
        path: buildLocalizedPath("sv", "admin").slice(1),
        lazy: () => import("./Pages/AdminPage"),
      },
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
