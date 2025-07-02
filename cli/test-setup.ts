import { afterEach, vi } from "vitest";

// Mock the command module using modern Vitest patterns
vi.mock("./lib/$.ts", () => ({
  $: vi.fn().mockImplementation(() => ({
    json: vi.fn().mockResolvedValue({}),
    text: vi.fn().mockResolvedValue(""),
    then: vi.fn().mockReturnValue({
      json: vi.fn().mockResolvedValue({}),
      text: vi.fn().mockResolvedValue(""),
    }),
  })),
}));

// Clean up mocks after each test
afterEach(() => {
  vi.clearAllMocks();
});
