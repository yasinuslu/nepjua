import { afterEach, vi } from "vitest";

// Mock the command module using modern Vitest patterns
vi.mock("./command.ts", () => ({
  $: vi.fn().mockImplementation(() => ({
    stdout: vi.fn().mockReturnThis(),
    then: vi.fn().mockResolvedValue({ stdoutJson: {}, text: "" }),
    text: vi.fn().mockResolvedValue(""),
    exec: vi.fn().mockResolvedValue(undefined),
  })),
}));

// Clean up mocks after each test
afterEach(() => {
  vi.clearAllMocks();
});
