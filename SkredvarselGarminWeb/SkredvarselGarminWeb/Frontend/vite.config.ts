import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { ViteImageOptimizer } from "vite-plugin-image-optimizer";

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
      },
      "/createSubscription": {
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
});
