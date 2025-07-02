import { describe, expect, it, vi } from "vitest";

// Mock @david/dax before importing the module
vi.mock("@david/dax", () => ({
  default: vi.fn(),
}));

import {
  getFullSecretName,
  getVaultName,
  parseFullSecretName,
  parseSecretPath,
  type SecretPath,
} from "./secret.ts";

describe("secret.ts", () => {
  describe("getVaultName", () => {
    it("should return global vault name for global secrets", () => {
      const result = getVaultName(true);
      expect(result).toBe("Nepjua Automation Global");
    });

    it("should return repo vault name for repository secrets", () => {
      const result = getVaultName(false);
      expect(result).toBe("Nepjua Automation");
    });
  });

  describe("parseSecretPath", () => {
    it("should parse simple key to main secret", () => {
      const result = parseSecretPath("github-token");
      const expected: SecretPath = {
        secretName: "main",
        fieldName: "github-token",
      };
      expect(result).toEqual(expected);
    });

    it("should parse nested path correctly", () => {
      const result = parseSecretPath("db/production/host");
      const expected: SecretPath = {
        secretName: "db/production",
        fieldName: "host",
      };
      expect(result).toEqual(expected);
    });

    it("should parse two-part path correctly", () => {
      const result = parseSecretPath("db/host");
      const expected: SecretPath = {
        secretName: "db",
        fieldName: "host",
      };
      expect(result).toEqual(expected);
    });

    it("should handle single character field names", () => {
      const result = parseSecretPath("config/x");
      const expected: SecretPath = {
        secretName: "config",
        fieldName: "x",
      };
      expect(result).toEqual(expected);
    });
  });

  describe("getFullSecretName", () => {
    it("should return secret name as-is for global secrets", () => {
      const result = getFullSecretName("main", "");
      expect(result).toBe("main");
    });

    it("should prepend namespace for repository secrets", () => {
      const result = getFullSecretName("main", "testuser/testrepo");
      expect(result).toBe("testuser/testrepo/main");
    });

    it("should handle complex secret names", () => {
      const result = getFullSecretName("db/production", "org/project");
      expect(result).toBe("org/project/db/production");
    });
  });

  describe("parseFullSecretName", () => {
    it("should return name as-is for global secrets", () => {
      const result = parseFullSecretName("main", "");
      expect(result).toBe("main");
    });

    it("should return complex name as-is for global secrets", () => {
      const result = parseFullSecretName("db/production", "");
      expect(result).toBe("db/production");
    });

    it("should extract secret name from namespaced name", () => {
      const result = parseFullSecretName(
        "testuser/testrepo/main",
        "testuser/testrepo"
      );
      expect(result).toBe("main");
    });

    it("should extract complex secret name from namespaced name", () => {
      const result = parseFullSecretName(
        "org/project/db/production",
        "org/project"
      );
      expect(result).toBe("db/production");
    });

    it("should return null for non-matching namespace", () => {
      const result = parseFullSecretName(
        "other/repo/main",
        "testuser/testrepo"
      );
      expect(result).toBeNull();
    });

    it("should return null for partial namespace match", () => {
      const result = parseFullSecretName(
        "testuser/testrepo-fork/main",
        "testuser/testrepo"
      );
      expect(result).toBeNull();
    });

    it("should handle empty secret name", () => {
      const result = parseFullSecretName("", "");
      expect(result).toBe("");
    });
  });
});
