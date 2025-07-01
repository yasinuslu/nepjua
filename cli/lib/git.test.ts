import { assertEquals, assertRejects } from "@std/assert";
import { afterEach, beforeEach, describe, it } from "@std/testing/bdd";
import { assertSpyCall, restore, stub } from "@std/testing/mock";

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
  let commandStub: any;

  beforeEach(() => {
    // Stub Deno.Command
    commandStub = stub(
      Deno,
      "Command",
      (...args: unknown[]) => new MockCommand(args[0] as string, args[1] as any)
    );
  });

  afterEach(() => {
    restore();
  });

  describe("gitFindRoot", () => {
    it("should return git root path when in a repository", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode("/path/to/repo\n"),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitFindRoot();
      assertEquals(result, "/path/to/repo");

      assertSpyCall(commandStub, 0, {
        args: [
          "git",
          {
            args: ["rev-parse", "--show-toplevel"],
            stdout: "piped",
            stderr: "piped",
          },
        ],
      });

      outputStub.restore();
    });

    it("should throw error when not in a git repository", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      await assertRejects(
        () => gitFindRoot(),
        Error,
        "Not in a git repository"
      );

      outputStub.restore();
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

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

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

      assertEquals(result, expected);

      outputStub.restore();
    });

    it("should handle empty remotes", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitGetRemotes();
      assertEquals(result, []);

      outputStub.restore();
    });

    it("should throw error when git command fails", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      await assertRejects(
        () => gitGetRemotes(),
        Error,
        "Failed to get git remotes"
      );

      outputStub.restore();
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

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitGetGitHubNamespace();

      const expected: GitNamespace = {
        owner: "user",
        repo: "repo",
        full: "user/repo",
      };

      assertEquals(result, expected);

      outputStub.restore();
    });

    it("should handle SSH URLs with profiles", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "origin\tgit@github.com-work:company/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitGetGitHubNamespace();

      const expected: GitNamespace = {
        owner: "company",
        repo: "repo",
        full: "company/repo",
      };

      assertEquals(result, expected);

      outputStub.restore();
    });

    it("should fall back to first GitHub remote when no origin", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "upstream\thttps://github.com/upstream/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitGetGitHubNamespace();

      const expected: GitNamespace = {
        owner: "upstream",
        repo: "repo",
        full: "upstream/repo",
      };

      assertEquals(result, expected);

      outputStub.restore();
    });

    it("should throw error when no GitHub remotes found", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(
          "origin\thttps://gitlab.com/user/repo.git (fetch)\n"
        ),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      await assertRejects(
        () => gitGetGitHubNamespace(),
        Error,
        "No GitHub remotes found"
      );

      outputStub.restore();
    });

    it("should throw error when no remotes found", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      await assertRejects(
        () => gitGetGitHubNamespace(),
        Error,
        "No git remotes found"
      );

      outputStub.restore();
    });
  });

  describe("gitIsRepository", () => {
    it("should return true when in a git repository", async () => {
      const mockOutput = {
        code: 0,
        stdout: new TextEncoder().encode("/path/to/repo\n"),
        stderr: new TextEncoder().encode(""),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitIsRepository();
      assertEquals(result, true);

      outputStub.restore();
    });

    it("should return false when not in a git repository", async () => {
      const mockOutput = {
        code: 1,
        stdout: new TextEncoder().encode(""),
        stderr: new TextEncoder().encode("fatal: not a git repository"),
      };

      const outputStub = stub(MockCommand.prototype, "output", () =>
        Promise.resolve(mockOutput)
      );

      const result = await gitIsRepository();
      assertEquals(result, false);

      outputStub.restore();
    });
  });
});
