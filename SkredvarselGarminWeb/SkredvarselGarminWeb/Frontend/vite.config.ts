import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
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
