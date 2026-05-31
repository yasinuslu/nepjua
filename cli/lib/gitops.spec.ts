import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import {
  gitopsAssembleBundle,
  gitopsBuildSopsKeysBundle,
  gitopsDiscoverRepoUrlsFromTenants,
  gitopsExtractAgeSecretKey,
  gitopsIsExcludedManifest,
  gitopsKubectlCreateNamespaceArgs,
  gitopsKubectlDockerRegistrySecretArgs,
  gitopsKubectlGenericSecretArgs,
  gitopsWithTempKeysFile,
} from "./gitops.ts";
import { opGetValue, warmupVaultCache } from "./op.ts";
import { gitGetGitHubNamespace } from "./git.ts";

vi.mock("./op.ts", () => ({
  opGetValue: vi.fn(),
  warmupVaultCache: vi.fn(),
}));

vi.mock("./git.ts", async (importOriginal) => {
  const actual = await importOriginal<typeof import("./git.ts")>();
  return { ...actual, gitGetGitHubNamespace: vi.fn() };
});

// `@std/yaml` (JSR) can't be resolved by vite; the wrapper is mocked so the
// orchestrator test exercises wiring without real YAML resolution. Real
// parsing is covered by the pure `gitopsDiscoverRepoUrlsFromTenants` test and
// verified under Deno at runtime.
vi.mock("./yaml.ts", () => ({
  parseAll: vi.fn((text: string) => {
    const m = text.match(/repoURL:\s*(\S+)/);
    return m ? [{ spec: { source: { repoURL: m[1] } } }] : [];
  }),
}));

function asyncDir(entries: Array<Partial<Deno.DirEntry>>) {
  return (async function* () {
    for (const e of entries) {
      yield { isFile: true, isDirectory: false, isSymlink: false, ...e } as Deno.DirEntry;
    }
  })();
}

const keyBlob = (key: string) =>
  `# created: 2026-05-31T00:00:00+03:00\n# public key: age1xxxx\n${key}\n`;

describe("gitops pure functions", () => {
  describe("gitopsDiscoverRepoUrlsFromTenants", () => {
    it("extracts spec.source.repoURL from each doc", () => {
      const docs = [
        { spec: { source: { repoURL: "https://github.com/yasinuslu/music-manager.git" } } },
        { spec: { source: { repoURL: "git@github.com:yasinuslu/other.git" } } },
      ];
      expect(gitopsDiscoverRepoUrlsFromTenants(docs)).toEqual([
        "https://github.com/yasinuslu/music-manager.git",
        "git@github.com:yasinuslu/other.git",
      ]);
    });

    it("ignores docs without spec.source.repoURL", () => {
      const docs = [
        { kind: "AppProject", spec: { sourceRepos: ["x"] } },
        { spec: { source: {} } },
        null,
        { spec: { source: { repoURL: "https://github.com/a/b.git" } } },
      ];
      expect(gitopsDiscoverRepoUrlsFromTenants(docs)).toEqual([
        "https://github.com/a/b.git",
      ]);
    });
  });

  describe("gitopsIsExcludedManifest", () => {
    it("excludes _-prefixed templates", () => {
      expect(gitopsIsExcludedManifest("_example-music-manager.yaml")).toBe(true);
      expect(gitopsIsExcludedManifest("tenants/_example.yaml")).toBe(true);
    });
    it("keeps real manifests", () => {
      expect(gitopsIsExcludedManifest("music-manager.yaml")).toBe(false);
      expect(gitopsIsExcludedManifest("tenants/music-manager.yaml")).toBe(false);
    });
  });

  describe("gitopsExtractAgeSecretKey", () => {
    it("extracts the private key line from a keygen blob", () => {
      expect(gitopsExtractAgeSecretKey(keyBlob("AGE-SECRET-KEY-ABC123"))).toBe(
        "AGE-SECRET-KEY-ABC123"
      );
    });
    it("returns null when no key present", () => {
      expect(gitopsExtractAgeSecretKey("# public key: age1xxxx\n")).toBeNull();
    });
  });

  describe("gitopsAssembleBundle", () => {
    it("dedupes, drops empties, preserves first-occurrence order, trailing newline", () => {
      const out = gitopsAssembleBundle([
        "AGE-SECRET-KEY-A",
        "  ",
        "AGE-SECRET-KEY-B",
        "AGE-SECRET-KEY-A",
        "",
      ]);
      expect(out).toBe("AGE-SECRET-KEY-A\nAGE-SECRET-KEY-B\n");
    });
    it("returns empty string for no keys", () => {
      expect(gitopsAssembleBundle([])).toBe("");
      expect(gitopsAssembleBundle(["", "  "])).toBe("");
    });
  });

  describe("kubectl argv builders", () => {
    it("namespace", () => {
      expect(gitopsKubectlCreateNamespaceArgs("argocd")).toEqual([
        "create", "namespace", "argocd", "--dry-run=client", "-o", "yaml",
      ]);
    });
    it("generic secret from file", () => {
      expect(
        gitopsKubectlGenericSecretArgs({
          name: "sops-age", namespace: "argocd", fileKey: "keys.txt", filePath: "/tmp/x",
        })
      ).toEqual([
        "create", "secret", "generic", "sops-age", "-n", "argocd",
        "--from-file=keys.txt=/tmp/x", "--dry-run=client", "-o", "yaml",
      ]);
    });
    it("docker-registry secret", () => {
      expect(
        gitopsKubectlDockerRegistrySecretArgs({
          name: "ghcr-pull", namespace: "argocd", server: "ghcr.io",
          username: "yasinuslu", password: "tok",
        })
      ).toEqual([
        "create", "secret", "docker-registry", "ghcr-pull", "-n", "argocd",
        "--docker-server=ghcr.io", "--docker-username=yasinuslu",
        "--docker-password=tok", "--dry-run=client", "-o", "yaml",
      ]);
    });
  });
});

describe("gitopsWithTempKeysFile", () => {
  beforeEach(() => {
    vi.spyOn(Deno, "makeTempFile").mockResolvedValue("/tmp/sops-age-xxx.txt");
    vi.spyOn(Deno, "writeTextFile").mockResolvedValue(undefined);
    vi.spyOn(Deno, "chmod").mockResolvedValue(undefined);
    vi.spyOn(Deno, "remove").mockResolvedValue(undefined);
  });
  afterEach(() => vi.restoreAllMocks());

  it("writes 0600, runs fn with the path, and removes the file", async () => {
    const result = await gitopsWithTempKeysFile("BUNDLE\n", async (p) => {
      expect(p).toBe("/tmp/sops-age-xxx.txt");
      return "ok";
    });
    expect(result).toBe("ok");
    expect(Deno.writeTextFile).toHaveBeenCalledWith("/tmp/sops-age-xxx.txt", "BUNDLE\n");
    expect(Deno.chmod).toHaveBeenCalledWith("/tmp/sops-age-xxx.txt", 0o600);
    expect(Deno.remove).toHaveBeenCalledWith("/tmp/sops-age-xxx.txt");
  });

  it("removes the temp file even when fn throws", async () => {
    await expect(
      gitopsWithTempKeysFile("B", async () => {
        throw new Error("boom");
      })
    ).rejects.toThrow("boom");
    expect(Deno.remove).toHaveBeenCalledWith("/tmp/sops-age-xxx.txt");
  });
});

describe("gitopsBuildSopsKeysBundle", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(gitGetGitHubNamespace).mockResolvedValue({
      owner: "yasinuslu",
      repo: "platform-gitops",
      full: "yasinuslu/platform-gitops",
    });
    vi.mocked(warmupVaultCache).mockResolvedValue([] as any);
    vi.spyOn(Deno, "readDir").mockReturnValue(
      asyncDir([
        { name: "music-manager.yaml" },
        { name: "_example-music-manager.yaml" },
        { name: "README.md" },
      ])
    );
    vi.spyOn(Deno, "readTextFile").mockResolvedValue(
      "spec:\n  source:\n    repoURL: https://github.com/yasinuslu/music-manager.git\n"
    );
  });
  afterEach(() => vi.restoreAllMocks());

  it("includes the platform repo key plus each discovered Project key", async () => {
    vi.mocked(opGetValue).mockImplementation(async (item: string) => {
      if (item.startsWith("yasinuslu/platform-gitops")) return keyBlob("AGE-SECRET-KEY-SELF");
      if (item.startsWith("yasinuslu/music-manager")) return keyBlob("AGE-SECRET-KEY-MM");
      throw new Error("not found");
    });

    const { bundle, included, skipped } = await gitopsBuildSopsKeysBundle({
      repoRoot: "/repo",
    });

    expect(included).toEqual(["yasinuslu/platform-gitops", "yasinuslu/music-manager"]);
    expect(skipped).toEqual([]);
    expect(bundle).toBe("AGE-SECRET-KEY-SELF\nAGE-SECRET-KEY-MM\n");
  });

  it("skips a Project whose key is missing in 1Password (no throw)", async () => {
    vi.mocked(opGetValue).mockImplementation(async (item: string) => {
      if (item.startsWith("yasinuslu/platform-gitops")) return keyBlob("AGE-SECRET-KEY-SELF");
      throw new Error("not found");
    });

    const { bundle, included, skipped } = await gitopsBuildSopsKeysBundle({
      repoRoot: "/repo",
    });

    expect(included).toEqual(["yasinuslu/platform-gitops"]);
    expect(skipped).toEqual(["yasinuslu/music-manager"]);
    expect(bundle).toBe("AGE-SECRET-KEY-SELF\n");
  });
});
