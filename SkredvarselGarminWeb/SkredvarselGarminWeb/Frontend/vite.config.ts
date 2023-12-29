import { defineConfig, splitVendorChunkPlugin } from "vite";
import react from "@vitejs/plugin-react";
import { imagetools } from "vite-imagetools";
import https from "https";

// https://vitejs.dev/config/
export default defineConfig({
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
    proxy: {
      "^/(vipps|google|facebook|logout|stripe).*": {
        target: "https://localhost:8080",
        changeOrigin: true,
        secure: false,
        agent: new https.Agent(),
      },
      "^/create(VippsAgreement|StripeSubscription)": {
        target: "https://localhost:8080",
        changeOrigin: true,
        secure: false,
        agent: new https.Agent(),
      },
      "^/api/.*": {
        target: "https://localhost:8080",
        changeOrigin: true,
        secure: false,
        agent: new https.Agent(),
      },
    },
  },
});
