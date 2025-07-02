import { afterEach, vi } from "vitest";

// Mock the $ module
vi.mock("zx", () => {
  const mock$ = vi.fn();

  return {
    $: mock$,
  };
});

// Clean up mocks after each test
afterEach(() => {
  vi.clearAllMocks();
});
