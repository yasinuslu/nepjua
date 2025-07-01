import { assertEquals } from "@std/assert";
import { describe, it } from "@std/testing/bdd";

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
      assertEquals(result, "Nepjua Automation Global");
    });

    it("should return repo vault name for repository secrets", () => {
      const result = getVaultName(false);
      assertEquals(result, "Nepjua Automation");
    });
  });

  describe("parseSecretPath", () => {
    it("should parse simple key to main secret", () => {
      const result = parseSecretPath("github-token");
      const expected: SecretPath = {
        secretName: "main",
        fieldName: "github-token",
      };
      assertEquals(result, expected);
    });

    it("should parse nested path correctly", () => {
      const result = parseSecretPath("db/production/host");
      const expected: SecretPath = {
        secretName: "db/production",
        fieldName: "host",
      };
      assertEquals(result, expected);
    });

    it("should parse two-part path correctly", () => {
      const result = parseSecretPath("db/host");
      const expected: SecretPath = {
        secretName: "db",
        fieldName: "host",
      };
      assertEquals(result, expected);
    });

    it("should handle single character field names", () => {
      const result = parseSecretPath("config/x");
      const expected: SecretPath = {
        secretName: "config",
        fieldName: "x",
      };
      assertEquals(result, expected);
    });
  });

  describe("getFullSecretName", () => {
    it("should return secret name as-is for global secrets", () => {
      const result = getFullSecretName("main", "");
      assertEquals(result, "main");
    });

    it("should prepend namespace for repository secrets", () => {
      const result = getFullSecretName("main", "testuser/testrepo");
      assertEquals(result, "testuser/testrepo/main");
    });

    it("should handle complex secret names", () => {
      const result = getFullSecretName("db/production", "org/project");
      assertEquals(result, "org/project/db/production");
    });
  });

  describe("parseFullSecretName", () => {
    it("should return name as-is for global secrets", () => {
      const result = parseFullSecretName("main", "");
      assertEquals(result, "main");
    });

    it("should return complex name as-is for global secrets", () => {
      const result = parseFullSecretName("db/production", "");
      assertEquals(result, "db/production");
    });

    it("should extract secret name from namespaced name", () => {
      const result = parseFullSecretName(
        "testuser/testrepo/main",
        "testuser/testrepo"
      );
      assertEquals(result, "main");
    });

    it("should extract complex secret name from namespaced name", () => {
      const result = parseFullSecretName(
        "org/project/db/production",
        "org/project"
      );
      assertEquals(result, "db/production");
    });

    it("should return null for non-matching namespace", () => {
      const result = parseFullSecretName(
        "other/repo/main",
        "testuser/testrepo"
      );
      assertEquals(result, null);
    });

    it("should return null for partial namespace match", () => {
      const result = parseFullSecretName(
        "testuser/testrepo-fork/main",
        "testuser/testrepo"
      );
      assertEquals(result, null);
    });

    it("should handle empty secret name", () => {
      const result = parseFullSecretName("", "");
      assertEquals(result, "");
    });
  });
});
