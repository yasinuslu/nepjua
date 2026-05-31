// Thin wrapper around the JSR YAML module so tests can mock YAML parsing
// without vite needing to resolve the `@std/yaml` JSR specifier.
export { parseAll } from "@std/yaml";
