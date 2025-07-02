import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import {
  gitFindRoot,
  gitGetGitHubNamespace,
  gitGetRemotes,
  gitIsRepository,
  type GitNamespace,
  type GitRemote,
} from "./git.ts";

// Mock Deno.Command
class MockCommand {
  constructor(
    public command: string,
    public options: { args: string[]; stdout: string; stderr: string }
  ) {}

  async output() {
    // This will be stubbed in tests
    return {
      code: 0,
      stdout: new TextEncoder().encode(""),
      stderr: new TextEncoder().encode(""),
    };
  }
}

describe("git.ts", () => {
  let commandSpy: any;

  beforeEach(() => {
    // Mock Deno.Command
    commandSpy = vi
      .spyOn(Deno, "Command")
      .mockImplementation(
        (...args: unknown[]) =>
          new MockCommand(args[0] as string, args[1] as any)
      );
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("gitFindRoot", () => {
    it("should return git root path when in a repository", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode("/path/to/repo\n"),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitFindRoot();
      expect(result).toBe("/path/to/repo");

      expect(commandSpy).toHaveBeenCalledWith("git", {
        args: ["rev-parse", "--show-toplevel"],
        stdout: "piped",
        stderr: "piped",
      });

      outputSpy.mockRestore();
    });

    it("should throw error when not in a git repository", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      await expect(gitFindRoot()).rejects.toThrow("Not in a git repository");

      outputSpy.mockRestore();
    });
  });

  describe("gitGetRemotes", () => {
    it("should parse git remotes correctly", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "origin\thttps://github.com/user/repo.git (fetch)\n" +
            "origin\thttps://github.com/user/repo.git (push)\n" +
            "upstream\tgit@github.com:upstream/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitGetRemotes();

      const expected: GitRemote[] = [
        {
          name: "origin",
          url: "https://github.com/user/repo.git",
          type: "fetch",
        },
        {
          name: "origin",
          url: "https://github.com/user/repo.git",
          type: "push",
        },
        {
          name: "upstream",
          url: "git@github.com:upstream/repo.git",
          type: "fetch",
        },
      ];

      expect(result).toEqual(expected);

      outputSpy.mockRestore();
    });

    it("should handle empty remotes", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitGetRemotes();
      expect(result).toEqual([]);

      outputSpy.mockRestore();
    });

    it("should throw error when git command fails", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      await expect(gitGetRemotes()).rejects.toThrow(
        "Failed to get git remotes"
      );

      outputSpy.mockRestore();
    });
  });

  describe("gitGetGitHubNamespace", () => {
    it("should return namespace from origin remote", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "origin\thttps://github.com/user/repo.git (fetch)\n" +
            "upstream\thttps://github.com/other/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitGetGitHubNamespace();

      const expected: GitNamespace = {
        owner: "user",
        repo: "repo",
        full: "user/repo",
      };

      expect(result).toEqual(expected);

      outputSpy.mockRestore();
    });

    it("should return namespace from SSH origin remote", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "origin\tgit@github.com:user/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitGetGitHubNamespace();

      const expected: GitNamespace = {
        owner: "user",
        repo: "repo",
        full: "user/repo",
      };

      expect(result).toEqual(expected);

      outputSpy.mockRestore();
    });

    it("should throw error when no GitHub remotes found", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "origin\thttps://gitlab.com/user/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      await expect(gitGetGitHubNamespace()).rejects.toThrow(
        "No GitHub remotes found"
      );

      outputSpy.mockRestore();
    });

    it("should throw error when git command fails", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      await expect(gitGetGitHubNamespace()).rejects.toThrow(
        "Failed to get git remotes"
      );

      outputSpy.mockRestore();
    });
  });

  describe("gitIsRepository", () => {
    it("should return true when in a git repository", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode("/path/to/repo\n"),
        stderr: new TextEncoder().encode(""),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitIsRepository();
      expect(result).toBe(true);

      outputSpy.mockRestore();
    });

    it("should return false when not in a git repository", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputSpy = vi
        .spyOn(MockCommand.prototype, "output")
        .mockResolvedValue(mockOutput);

      const result = await gitIsRepository();
      expect(result).toBe(false);

      outputSpy.mockRestore();
    });
  });
});
