import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { imagetools } from "vite-imagetools";
import https from "https";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), imagetools()],
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
