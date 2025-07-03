import { beforeEach, describe, expect, it, vi } from "vitest";
import { $ } from "./$.ts";
import { ensureLinesInFile } from "./fs.ts";
import {
  externalSecretArchive,
  externalSecretGet,
  setSecret,
} from "./secret.ts";
import { sopsBootstrap, sopsSetup } from "./sops.ts";
import { createDenoMocks, createMock$ } from "./test-utils.ts";

// Get access to the mocked $ function
const mock$ = vi.mocked($);

// Mock dependencies
vi.mock("./secret.ts", { spy: true });
vi.mock("./fs.ts", { spy: true });

describe("sops lib", () => {
  let denoMocks: ReturnType<typeof createDenoMocks>;

  beforeEach(() => {
    vi.clearAllMocks();

    // Create fresh Deno mocks for each test
    denoMocks = createDenoMocks();

    // Spy on Deno methods instead of replacing the whole object
    vi.spyOn(Deno, "stat").mockImplementation(denoMocks.stat);
    vi.spyOn(Deno, "readTextFile").mockImplementation(denoMocks.readTextFile);
    vi.spyOn(Deno, "writeTextFile").mockImplementation(denoMocks.writeTextFile);
    vi.spyOn(Deno, "mkdir").mockImplementation(denoMocks.mkdir);
    vi.spyOn(Deno, "chmod").mockImplementation(denoMocks.chmod);
  });

  describe("sopsBootstrap", () => {
    const mockKeyOutput = `# created: 2024-01-01T00:00:00Z
# public key: age1abcdef123456789
AGE-SECRET-KEY-1ABCDEF123456789...`;

    it("should successfully bootstrap SOPS when no existing config", async () => {
      // Setup: no existing files/keys
      denoMocks.stat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(externalSecretGet).mockRejectedValue(new Error("Not found"));

      mock$.mockReturnValue(createMock$({ text: mockKeyOutput }));

      vi.mocked(setSecret).mockResolvedValue(undefined);
      vi.mocked(ensureLinesInFile).mockResolvedValue(undefined);
      denoMocks.writeTextFile.mockResolvedValue(undefined);

      const result = await sopsBootstrap();

      expect(result).toEqual({
        publicKey: "age1abcdef123456789",
        configCreated: true,
        gitignoreUpdated: true,
        keyArchived: false,
      });

      expect(mock$).toHaveBeenCalled();
      expect(vi.mocked(setSecret)).toHaveBeenCalledWith(
        "SOPS/age-key",
        mockKeyOutput.trim(),
        false
      );
      expect(denoMocks.writeTextFile).toHaveBeenCalledWith(
        ".sops.yaml",
        "creation_rules:\n  - age: age1abcdef123456789\n"
      );
      expect(vi.mocked(ensureLinesInFile)).toHaveBeenCalledWith(".gitignore", [
        "# SOPS",
        ".sops/",
        "*.age",
        ".tmp",
        "*.enc.tmp.*",
      ]);
    });

    it("should refuse to bootstrap when .sops.yaml exists without force", async () => {
      denoMocks.stat.mockResolvedValue({} as Deno.FileInfo);

      await expect(sopsBootstrap()).rejects.toThrow(
        ".sops.yaml already exists. Use --force to override."
      );
    });

    it("should refuse to bootstrap when SOPS key exists without force", async () => {
      denoMocks.stat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(externalSecretGet).mockResolvedValue("existing-key");

      await expect(sopsBootstrap()).rejects.toThrow(
        "SOPS AGE key already exists. Use --force to override."
      );
    });

    it("should force bootstrap and archive existing key", async () => {
      // Setup: existing files/keys
      denoMocks.stat.mockResolvedValue({} as Deno.FileInfo);
      vi.mocked(externalSecretGet).mockResolvedValue("existing-key");
      vi.mocked(externalSecretArchive).mockResolvedValue({
        archivePath: "archive/SOPS/age-key/mock-timestamp",
        originalPath: "SOPS/age-key",
      });

      mock$.mockReturnValue(createMock$({ text: mockKeyOutput }));

      vi.mocked(setSecret).mockResolvedValue(undefined);
      vi.mocked(ensureLinesInFile).mockResolvedValue(undefined);
      denoMocks.writeTextFile.mockResolvedValue(undefined);

      const result = await sopsBootstrap({ force: true });

      expect(result).toEqual({
        publicKey: "age1abcdef123456789",
        configCreated: true,
        gitignoreUpdated: true,
        keyArchived: true,
      });

      expect(vi.mocked(externalSecretArchive)).toHaveBeenCalledWith(
        "SOPS/age-key",
        "Replaced by new bootstrap",
        false
      );
    });

    it("should not update gitignore if SOPS entries already exist", async () => {
      denoMocks.stat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(externalSecretGet).mockRejectedValue(new Error("Not found"));

      mock$.mockReturnValue(createMock$({ text: mockKeyOutput }));

      vi.mocked(setSecret).mockResolvedValue(undefined);
      vi.mocked(ensureLinesInFile).mockResolvedValue(undefined);
      denoMocks.writeTextFile.mockResolvedValue(undefined);

      const result = await sopsBootstrap();

      expect(result.gitignoreUpdated).toBe(true);
      expect(denoMocks.writeTextFile).toHaveBeenCalledTimes(1); // Only .sops.yaml
    });

    it("should fail when age-keygen output is invalid", async () => {
      denoMocks.stat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(externalSecretGet).mockRejectedValue(new Error("Not found"));

      mock$.mockReturnValue(createMock$({ text: "invalid output" }));

      await expect(sopsBootstrap()).rejects.toThrow(
        "Failed to extract public key from age-keygen output"
      );
    });
  });

  describe("sopsSetup", () => {
    it("should successfully set up SOPS", async () => {
      const mockKeyData = "AGE-SECRET-KEY-1ABCDEF123456789...";
      vi.mocked(externalSecretGet).mockResolvedValue(mockKeyData);
      vi.mocked(ensureLinesInFile).mockResolvedValue(undefined);
      denoMocks.mkdir.mockResolvedValue(undefined);
      denoMocks.writeTextFile.mockResolvedValue(undefined);
      denoMocks.chmod.mockResolvedValue(undefined);

      const result = await sopsSetup();

      expect(result).toEqual({
        keyPath: ".sops/age-key.txt",
        keyWritten: true,
      });

      expect(vi.mocked(externalSecretGet)).toHaveBeenCalledWith(
        "SOPS/age-key",
        false
      );
      expect(denoMocks.mkdir).toHaveBeenCalledWith(".sops", {
        recursive: true,
      });
      expect(denoMocks.writeTextFile).toHaveBeenCalledWith(
        ".sops/age-key.txt",
        mockKeyData
      );
      expect(denoMocks.chmod).toHaveBeenCalledWith(".sops/age-key.txt", 0o600);
    });

    it("should fail when SOPS key doesn't exist", async () => {
      vi.mocked(externalSecretGet).mockRejectedValue(new Error("Not found"));

      await expect(sopsSetup()).rejects.toThrow(
        "Failed to retrieve SOPS AGE key. Run 'nep sops bootstrap' first to set up SOPS"
      );
    });
  });
});
