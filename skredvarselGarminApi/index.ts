import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
import {
  createProxyMiddleware,
  responseInterceptor,
} from "http-proxy-middleware";
import { VarsomAvalancheWarning, VarsomRegionSummary } from "./types";
import { mapToAvalanceWarning, mapToRegionSummary } from "./mappers";

dotenv.config();

const app: Express = express();
const port = process.env.PORT || "8080";
const baseUrl = "https://api01.nve.no/hydrology/forecast/avalanche/v6.2.1/api";

app.get("/", (_req: Request, res: Response) => {
  res.send("Express + TypeScript Server");
});

app.get(
  "/regionSummary",
  createProxyMiddleware({
    target: `${baseUrl}/RegionSummary/Simple/1`,
    headers: {
      Accept: "application/json",
    },
    changeOrigin: true,
    logger: console,
    selfHandleResponse: true,
    on: {
      proxyRes: responseInterceptor(async (responseBuffer) => {
        const data = JSON.parse(
          responseBuffer.toString("utf8")
        ) as VarsomRegionSummary[];

        const mapped = data.map(mapToRegionSummary);

        return JSON.stringify(mapped);
      }),
    },
  })
);

app.get(
  "/avalancheWarningByRegion/:regionId/:lang/:from/:to",
  createProxyMiddleware({
    target: `${baseUrl}/AvalancheWarningByRegion/Simple`,
    logger: console,
    pathRewrite: {
      "^/avalancheWarningByRegion/": "/", // remove base path
    },
    changeOrigin: true,
    headers: {
      Accept: "application/json",
    },
    selfHandleResponse: true,
    on: {
      proxyRes: responseInterceptor(async (responseBuffer) => {
        const data = JSON.parse(
          responseBuffer.toString("utf8")
        ) as VarsomAvalancheWarning[];

        const mapped = data.map(mapToAvalanceWarning);

        return JSON.stringify(mapped);
      }),
    },
  })
);

app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at http://localhost:${port}`);
});
