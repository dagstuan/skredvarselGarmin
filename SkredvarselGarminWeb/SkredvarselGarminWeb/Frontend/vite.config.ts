import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { ViteImageOptimizer } from "vite-plugin-image-optimizer";
import https from "https";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    ViteImageOptimizer({
      jpeg: {
        // https://sharp.pixelplumbing.com/api-output#jpeg
        quality: 80,
      },
    }),
  ],
  server: {
    proxy: {
      "^/vipps.*": {
        target: "https://localhost:8080",
        changeOrigin: true,
        secure: false,
        agent: new https.Agent(),
      },
      "/createSubscription": {
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
