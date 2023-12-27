import { ChakraProvider } from "@chakra-ui/react";
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "react-query";
import { ReactQueryDevtools } from "react-query/devtools";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import App from "./App";
import ErrorPage from "./Components/ErrorPage";
import { FaqPage } from "./Components/FaqPage";
import { FrontPage } from "./Components/FrontPage";
import { PrivacyPolicy } from "./Components/PrivacyPolicy";
import { SalesConditions } from "./Components/SalesConditions";
import { RequireAdmin } from "./Components/Admin/RequireAdmin";
import { AdminPage } from "./Components/Admin/AdminPage";

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
        element: <FrontPage />,
        children: [
          {
            path: "minSide",
          },
          {
            path: "subscribe",
          },
        ],
      },
      {
        path: "faq",
        element: <FaqPage />,
      },
      {
        path: "salgsbetingelser",
        element: <SalesConditions />,
      },
      {
        path: "personvern",
        element: <PrivacyPolicy />,
      },
      {
        path: "admin",
        element: (
          <RequireAdmin>
            <AdminPage />
          </RequireAdmin>
        ),
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
