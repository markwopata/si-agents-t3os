import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const widgetsUrl = process.env.VITE_T3OS_WIDGETS_URL || "https://staging-widgets.t3os.ai";

export default defineConfig({
  plugins: [
    react(),
    {
      name: "html-env-transform",
      transformIndexHtml: {
        order: "pre",
        handler(html) {
          return html.replace(/%VITE_T3OS_WIDGETS_URL%/g, widgetsUrl);
        },
      },
    },
  ],
  server: {
    host: true,
    port: 3000,
    strictPort: true,
  },
});
