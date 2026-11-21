import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// In the monolith setup the React app builds into Phoenix's priv/static so
// Phoenix serves it at :4000. In dev you can instead run `npm run dev` for HMR,
// which proxies API calls through to the Phoenix server.
export default defineConfig({
  plugins: [react()],
  base: "/",
  build: {
    outDir: "../priv/static",
    // Keep favicon.ico / robots.txt that Phoenix generated.
    emptyOutDir: false,
    rollupOptions: {
      output: {
        entryFileNames: "assets/[name].js",
        chunkFileNames: "assets/[name].js",
        assetFileNames: "assets/[name][extname]",
      },
    },
  },
  server: {
    port: 5173,
    proxy: {
      "/api": "http://localhost:4000",
      "/graphiql": "http://localhost:4000",
    },
  },
});
