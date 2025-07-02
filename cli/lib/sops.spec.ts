import { beforeEach, describe, expect, it, vi } from "vitest";
import { $ } from "./command.ts";
import { archiveSecret, getSecret, setSecret } from "./secret.ts";
import { sopsBootstrap, sopsSetup } from "./sops.ts";

// Mock dependencies
vi.mock("./command.ts", { spy: true });
vi.mock("./secret.ts", { spy: true });

// Mock Deno APIs
const mockStat = vi.fn();
const mockReadTextFile = vi.fn();
const mockWriteTextFile = vi.fn();
const mockMkdir = vi.fn();
const mockChmod = vi.fn();

// Monkey patch Deno for tests
(globalThis as any).Deno = {
  stat: mockStat,
  readTextFile: mockReadTextFile,
  writeTextFile: mockWriteTextFile,
  mkdir: mockMkdir,
  chmod: mockChmod,
};

describe("sops lib", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("sopsBootstrap", () => {
    const mockKeyOutput = `# created: 2024-01-01T00:00:00Z
# public key: age1abcdef123456789
AGE-SECRET-KEY-1ABCDEF123456789...`;

    it("should successfully bootstrap SOPS when no existing config", async () => {
      // Setup: no existing files/keys
      mockStat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(getSecret).mockRejectedValue(new Error("Not found"));
      vi.mocked($).mockReturnValue({
        text: () => Promise.resolve(mockKeyOutput),
      } as any);
      vi.mocked(setSecret).mockResolvedValue();
      mockReadTextFile.mockRejectedValue(new Error("ENOENT"));
      mockWriteTextFile.mockResolvedValue();

      const result = await sopsBootstrap();

      expect(result).toEqual({
        publicKey: "age1abcdef123456789",
        configCreated: true,
        gitignoreUpdated: true,
        keyArchived: false,
      });

      expect(vi.mocked($)).toHaveBeenCalledWith(["age-keygen"]);
      expect(vi.mocked(setSecret)).toHaveBeenCalledWith(
        "SOPS/age-key",
        mockKeyOutput.trim(),
        false
      );
      expect(mockWriteTextFile).toHaveBeenCalledWith(
        ".sops.yaml",
        "creation_rules:\n  - age: age1abcdef123456789\n"
      );
      expect(mockWriteTextFile).toHaveBeenCalledWith(
        ".gitignore",
        "\n# SOPS\n.sops/\n*.age\n"
      );
    });

    it("should refuse to bootstrap when .sops.yaml exists without force", async () => {
      mockStat.mockResolvedValue({});

      await expect(sopsBootstrap()).rejects.toThrow(
        ".sops.yaml already exists. Use --force to override."
      );
    });

    it("should refuse to bootstrap when SOPS key exists without force", async () => {
      mockStat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(getSecret).mockResolvedValue("existing-key");

      await expect(sopsBootstrap()).rejects.toThrow(
        "SOPS AGE key already exists. Use --force to override."
      );
    });

    it("should force bootstrap and archive existing key", async () => {
      // Setup: existing files/keys
      mockStat.mockResolvedValue({});
      vi.mocked(getSecret).mockResolvedValue("existing-key");
      vi.mocked(archiveSecret).mockResolvedValue();
      vi.mocked($).mockReturnValue({
        text: () => Promise.resolve(mockKeyOutput),
      } as any);
      vi.mocked(setSecret).mockResolvedValue();
      mockReadTextFile.mockResolvedValue("existing gitignore\n.sops/\n");
      mockWriteTextFile.mockResolvedValue();

      const result = await sopsBootstrap({ force: true });

      expect(result).toEqual({
        publicKey: "age1abcdef123456789",
        configCreated: true,
        gitignoreUpdated: false,
        keyArchived: true,
      });

      expect(vi.mocked(archiveSecret)).toHaveBeenCalledWith(
        "SOPS/age-key",
        "Replaced by new bootstrap",
        false
      );
    });

    it("should not update gitignore if SOPS entries already exist", async () => {
      mockStat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(getSecret).mockRejectedValue(new Error("Not found"));
      vi.mocked($).mockReturnValue({
        text: () => Promise.resolve(mockKeyOutput),
      } as any);
      vi.mocked(setSecret).mockResolvedValue();
      mockReadTextFile.mockResolvedValue("existing gitignore\n.sops/\n");
      mockWriteTextFile.mockResolvedValue();

      const result = await sopsBootstrap();

      expect(result.gitignoreUpdated).toBe(false);
      expect(mockWriteTextFile).toHaveBeenCalledTimes(1); // Only .sops.yaml
    });

    it("should fail when age-keygen output is invalid", async () => {
      mockStat.mockRejectedValue(new Error("ENOENT"));
      vi.mocked(getSecret).mockRejectedValue(new Error("Not found"));
      vi.mocked($).mockReturnValue({
        text: () => Promise.resolve("invalid output"),
      } as any);

      await expect(sopsBootstrap()).rejects.toThrow(
        "Failed to extract public key from age-keygen output"
      );
    });
  });

  describe("sopsSetup", () => {
    it("should successfully set up SOPS", async () => {
      const mockKeyData = "AGE-SECRET-KEY-1ABCDEF123456789...";
      vi.mocked(getSecret).mockResolvedValue(mockKeyData);
      mockMkdir.mockResolvedValue();
      mockWriteTextFile.mockResolvedValue();
      mockChmod.mockResolvedValue();

      const result = await sopsSetup();

      expect(result).toEqual({
        keyPath: ".sops/age-key.txt",
        keyWritten: true,
      });

      expect(vi.mocked(getSecret)).toHaveBeenCalledWith("SOPS/age-key", false);
      expect(mockMkdir).toHaveBeenCalledWith(".sops", { recursive: true });
      expect(mockWriteTextFile).toHaveBeenCalledWith(
        ".sops/age-key.txt",
        mockKeyData
      );
      expect(mockChmod).toHaveBeenCalledWith(".sops/age-key.txt", 0o600);
    });

    it("should fail when SOPS key doesn't exist", async () => {
      vi.mocked(getSecret).mockRejectedValue(new Error("Not found"));

      await expect(sopsSetup()).rejects.toThrow(
        "Failed to retrieve SOPS AGE key. Run 'nep sops bootstrap' first to set up SOPS"
      );
    });
  });
});
