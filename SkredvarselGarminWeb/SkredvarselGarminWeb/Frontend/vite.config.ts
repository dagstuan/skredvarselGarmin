import { defineConfig, splitVendorChunkPlugin } from "vite";
import react from "@vitejs/plugin-react";
import { imagetools } from "vite-imagetools";
import https from "https";
import { spawn } from "child_process";
import fs from "fs";
import path from "path";

// Get base folder for certificates.
const baseFolder =
  process.env.APPDATA !== undefined && process.env.APPDATA !== ""
    ? `${process.env.APPDATA}/ASP.NET/https`
    : `${process.env.HOME}/.aspnet/https`;

// Generate the certificate name using the NPM package name
const certificateName = process.env.npm_package_name;

// Define certificate filepath
const certFilePath = path.join(baseFolder, `${certificateName}.pem`);
// Define key filepath
const keyFilePath = path.join(baseFolder, `${certificateName}.key`);

// https://vitejs.dev/config/
export default defineConfig(async () => {
  if (
    process.env.NODE_ENV !== "production" &&
    (!fs.existsSync(certFilePath) || !fs.existsSync(keyFilePath))
  ) {
    // Wait for the certificate to be generated
    await new Promise<void>((resolve) => {
      spawn(
        "dotnet",
        [
          "dev-certs",
          "https",
          "--export-path",
          certFilePath,
          "--format",
          "Pem",
          "--no-password",
        ],
        { stdio: "inherit" },
      ).on("exit", (code) => {
        resolve();
        if (code) {
          process.exit(code);
        }
      });
    });
  }

  return {
    plugins: [react(), imagetools(), splitVendorChunkPlugin()],
    build: {
      rollupOptions: {
        output: {
          manualChunks(id: string) {
            // creating a chunk to @open-ish deps. Reducing the vendor chunk size
            if (
              id.includes("@chakra-ui") ||
              id.includes("@emotion") ||
              id.includes("framer-motion")
            ) {
              return "@chakra-ui";
            }
            // creating a chunk to react routes deps. Reducing the vendor chunk size
            if (
              id.includes("react-router-dom") ||
              id.includes("@remix-run") ||
              id.includes("react-router")
            ) {
              return "@react-router";
            }
          },
        },
      },
    },
    server: {
      strictPort: true,
      https: {
        cert: certFilePath,
        key: keyFilePath,
      },
      proxy: {
        "^/(vipps|google|facebook|logout|stripe|email).*": {
          target: "https://localhost:8080",
          changeOrigin: true,
          secure: false,
        },
        "^/create(VippsAgreement|StripeSubscription)": {
          target: "https://localhost:8080",
          changeOrigin: true,
          secure: false,
        },
        "^/api/.*": {
          target: "https://localhost:8080",
          changeOrigin: true,
          secure: false,
        },
      },
    },
  };
});
