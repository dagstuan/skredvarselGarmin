import "./index.css";
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createBrowserRouter,
  Navigate,
  RouterProvider,
} from "react-router-dom";
import App from "./App";
import ErrorPage from "./Components/ErrorPage";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { Toaster } from "./Components/ui/toast";

// Remove facebook oauth redirect hash.
if (window.location.hash === "#_=_") {
  history.replaceState
    ? history.replaceState(null, "", window.location.href.split("#")[0])
    : (window.location.hash = "");
}

export const queryClient = new QueryClient();

const hydrateFallbackElement = (
  <div className="flex min-h-[40vh] items-center justify-center p-6 text-sm text-muted-foreground">
    Laster...
  </div>
);

const router = createBrowserRouter([
  {
    element: <App />,
    errorElement: <ErrorPage />,
    children: [
      {
        hydrateFallbackElement,
        path: "/",
        lazy: () => import("./Pages/FrontPage"),
        children: [
          {
            hydrateFallbackElement,
            path: "account",
            lazy: () => import("./Pages/AccountPage"),
          },
          {
            path: "minSide",
            element: <Navigate to="/account" replace />,
          },
          {
            hydrateFallbackElement,
            path: "subscribe",
            lazy: () => import("./Pages/BuySubscriptionModalPage"),
          },
          {
            hydrateFallbackElement,
            path: "addwatch",
            lazy: () => import("./Pages/AddWatchModalPage"),
          },
          {
            hydrateFallbackElement,
            path: "login",
            lazy: () => import("./Pages/LoginModalPage"),
          },
        ],
      },
      {
        hydrateFallbackElement,
        path: "faq",
        lazy: () => import("./Pages/FaqPage"),
      },
      {
        path: "salgsbetingelser",
        element: <Navigate to="/privacy" replace />,
      },
      {
        hydrateFallbackElement,
        path: "salesconditions",
        lazy: () => import("./Pages/SalesConditionsPage"),
      },
      {
        path: "personvern",
        element: <Navigate to="/privacy" replace />,
      },
      {
        hydrateFallbackElement,
        path: "privacy",
        lazy: () => import("./Pages/PrivacyPolicyPage"),
      },
      {
        hydrateFallbackElement,
        path: "admin",
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
