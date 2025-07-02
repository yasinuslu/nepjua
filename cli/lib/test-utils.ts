import { vi } from "vitest";

// Utility to create mock $ responses with different behaviors
export function createMock$(
  options: {
    text?: string;
    json?: any;
    error?: Error;
    shouldReject?: boolean;
  } = {}
) {
  const { text = "", json = {}, error, shouldReject = false } = options;

  if (error || shouldReject) {
    const mockError = error || new Error("Mock error");
    const rejectedPromise = Promise.reject(mockError);

    // Add catch handler to silence unhandled rejection warnings
    rejectedPromise.catch(() => {});

    // Create a thenable object that rejects
    const mockProcess = {
      json: vi.fn().mockRejectedValue(mockError),
      text: vi.fn().mockRejectedValue(mockError),
      exec: vi.fn().mockRejectedValue(mockError),
      then: rejectedPromise.then.bind(rejectedPromise),
      catch: rejectedPromise.catch.bind(rejectedPromise),
    };

    return mockProcess;
  }

  // Create a resolved promise for successful cases
  const resolvedPromise = Promise.resolve({
    stdout: "",
    stderr: "",
    exitCode: 0,
  });

  return {
    json: vi.fn().mockResolvedValue(json),
    text: vi.fn().mockResolvedValue(text),
    exec: vi.fn().mockResolvedValue(undefined),
    then: resolvedPromise.then.bind(resolvedPromise),
    catch: resolvedPromise.catch.bind(resolvedPromise),
  };
}

// Utility to create Deno API mocks
export function createDenoMocks() {
  return {
    stat: vi.fn(),
    readTextFile: vi.fn(),
    writeTextFile: vi.fn(),
    mkdir: vi.fn(),
    chmod: vi.fn(),
  };
}
