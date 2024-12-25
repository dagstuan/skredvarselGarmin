import { ChakraProvider } from "@chakra-ui/react";
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

// Remove facebook oauth redirect hash.
if (window.location.hash === "#_=_") {
  history.replaceState
    ? history.replaceState(null, "", window.location.href.split("#")[0])
    : (window.location.hash = "");
}

export const queryClient = new QueryClient();

const router = createBrowserRouter([
  {
    element: <App />,
    errorElement: <ErrorPage />,
    children: [
      {
        path: "/",
        lazy: () => import("./Pages/FrontPage"),
        children: [
          {
            path: "account",
            lazy: () => import("./Pages/AccountPage"),
          },
          {
            path: "minSide",
            element: <Navigate to="/account" replace />,
          },
          {
            path: "subscribe",
            lazy: () => import("./Pages/BuySubscriptionModalPage"),
          },
          {
            path: "addwatch",
            lazy: () => import("./Pages/AddWatchModalPage"),
          },
          {
            path: "login",
            lazy: () => import("./Pages/LoginModalPage"),
          },
        ],
      },
      {
        path: "faq",
        lazy: () => import("./Pages/FaqPage"),
      },
      {
        path: "salgsbetingelser",
        element: <Navigate to="/privacy" replace />,
      },
      {
        path: "salesconditions",
        lazy: () => import("./Pages/SalesConditionsPage"),
      },
      {
        path: "personvern",
        element: <Navigate to="/privacy" replace />,
      },
      {
        path: "privacy",
        lazy: () => import("./Pages/PrivacyPolicyPage"),
      },
      {
        path: "admin",
        lazy: () => import("./Pages/AdminPage"),
      },
    ],
  },
]);

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <ChakraProvider>
        <RouterProvider router={router} />
        <ReactQueryDevtools initialIsOpen={false} />
      </ChakraProvider>
    </QueryClientProvider>
  </React.StrictMode>,
);
