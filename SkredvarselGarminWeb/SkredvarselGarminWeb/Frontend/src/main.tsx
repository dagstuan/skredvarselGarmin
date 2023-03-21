import { ChakraProvider } from "@chakra-ui/react";
import { AxiosError } from "axios";
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryCache, QueryClient, QueryClientProvider } from "react-query";
import { ReactQueryDevtools } from "react-query/devtools";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import App from "./App";
import ErrorPage from "./Components/ErrorPage";
import { FrontPage } from "./Components/FrontPage";
import { PrivacyPolicy } from "./Components/PrivacyPolicy";
import { SalesConditions } from "./Components/SalesConditions";

export const queryClient = new QueryClient();

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    errorElement: <ErrorPage />,
    children: [
      {
        element: <FrontPage />,
        index: true,
      },
      {
        path: "minSide",
        element: <FrontPage />,
      },
      {
        path: "salgsbetingelser",
        element: <SalesConditions />,
      },
      {
        path: "personvern",
        element: <PrivacyPolicy />,
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
  </React.StrictMode>
);
