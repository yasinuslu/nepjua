import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["**/*.spec.ts"],
    exclude: ["**/node_modules/**", "**/dist/**"],
    environment: "node",
    globals: false,
    setupFiles: ["./cli/lib/test-setup.ts"],
  },
  resolve: {
    alias: {
      "@david/dax": "jsr:@david/dax@^0.43.1",
      "@cliffy/command": "jsr:@cliffy/command@^1.0.0-rc.7",
    },
  },
});
