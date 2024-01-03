import { ChakraProvider } from "@chakra-ui/react";
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "react-query";
import { ReactQueryDevtools } from "react-query/devtools";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import App from "./App";
import ErrorPage from "./Components/ErrorPage";

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
            path: "subscribe",
            lazy: () => import("./Pages/BuySubscriptionModalPage"),
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
        path: "salesconditions",
        lazy: () => import("./Pages/SalesConditionsPage"),
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
