import path from "node:path";
import { $ } from "zx";
import { externalSecretGetVaultName } from "./external-secret.ts";
import { gitGetGitHubNamespace, gitParseGitHubUrl } from "./git.ts";
import { opGetValue, warmupVaultCache } from "./op.ts";
import { parseAll } from "./yaml.ts";

const SOPS_KEY_SECRET_NAME = "SOPS/age-key";

// ---------------------------------------------------------------------------
// Pure functions (no IO — the primary TDD targets)
// ---------------------------------------------------------------------------

/**
 * Extract `spec.source.repoURL` from each parsed `tenants/*.yaml` document
 * (ArgoCD root Applications). Documents without that path are ignored.
 */
export function gitopsDiscoverRepoUrlsFromTenants(docs: unknown[]): string[] {
  const urls: string[] = [];
  for (const doc of docs) {
    const repoURL = (doc as any)?.spec?.source?.repoURL;
    if (typeof repoURL === "string" && repoURL.trim() !== "") {
      urls.push(repoURL.trim());
    }
  }
  return urls;
}

/**
 * Registry manifests whose basename starts with `_` are templates/examples
 * (e.g. `_example-music-manager.yaml`) and are excluded from discovery.
 */
export function gitopsIsExcludedManifest(name: string): boolean {
  return path.basename(name).startsWith("_");
}

/**
 * Pull the single `AGE-SECRET-KEY-…` line out of a stored age-keygen blob
 * (which also contains `# created:` / `# public key:` comment lines).
 */
export function gitopsExtractAgeSecretKey(blob: string): string | null {
  const match = blob.match(/AGE-SECRET-KEY-[A-Z0-9]+/);
  return match ? match[0] : null;
}

/**
 * Concatenate per-repo private keys into one `keys.txt` body: dedupe
 * (first-occurrence order), drop empties, one key per line, trailing newline.
 * SOPS/age tries each key in turn until one decrypts.
 */
export function gitopsAssembleBundle(keys: string[]): string {
  const seen = new Set<string>();
  const ordered: string[] = [];
  for (const key of keys) {
    const trimmed = key.trim();
    if (trimmed === "" || seen.has(trimmed)) continue;
    seen.add(trimmed);
    ordered.push(trimmed);
  }
  return ordered.length === 0 ? "" : ordered.join("\n") + "\n";
}

// --- kubectl argv builders (pure; the exec wrappers below are thin glue) ----

export function gitopsKubectlCreateNamespaceArgs(namespace: string): string[] {
  return [
    "create",
    "namespace",
    namespace,
    "--dry-run=client",
    "-o",
    "yaml",
  ];
}

export function gitopsKubectlGenericSecretArgs(opts: {
  name: string;
  namespace: string;
  fileKey: string;
  filePath: string;
}): string[] {
  return [
    "create",
    "secret",
    "generic",
    opts.name,
    "-n",
    opts.namespace,
    `--from-file=${opts.fileKey}=${opts.filePath}`,
    "--dry-run=client",
    "-o",
    "yaml",
  ];
}

export function gitopsKubectlDockerRegistrySecretArgs(opts: {
  name: string;
  namespace: string;
  server: string;
  username: string;
  password: string;
}): string[] {
  return [
    "create",
    "secret",
    "docker-registry",
    opts.name,
    "-n",
    opts.namespace,
    `--docker-server=${opts.server}`,
    `--docker-username=${opts.username}`,
    `--docker-password=${opts.password}`,
    "--dry-run=client",
    "-o",
    "yaml",
  ];
}

// ---------------------------------------------------------------------------
// IO functions
// ---------------------------------------------------------------------------

/**
 * Read and parse every non-excluded `*.yaml`/`*.yml` in `<repoRoot>/tenants`.
 * Returns the flattened list of YAML documents (multi-doc files supported).
 * A missing `tenants/` directory yields an empty list.
 */
export async function gitopsReadTenantDocs(
  repoRoot: string
): Promise<unknown[]> {
  const tenantsDir = path.join(repoRoot, "tenants");
  const docs: unknown[] = [];
  let entries: AsyncIterable<Deno.DirEntry>;
  try {
    entries = Deno.readDir(tenantsDir);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return docs;
    throw error;
  }
  for await (const entry of entries) {
    if (!entry.isFile) continue;
    if (!/\.(ya?ml)$/.test(entry.name)) continue;
    if (gitopsIsExcludedManifest(entry.name)) continue;
    const text = await Deno.readTextFile(path.join(tenantsDir, entry.name));
    for (const doc of parseAll(text) as unknown[]) {
      if (doc != null) docs.push(doc);
    }
  }
  return docs;
}

/**
 * Read a repo's private age key from 1Password (`{owner}/{repo}/SOPS/age-key`
 * in the "Nepjua Automation" vault) and return just the `AGE-SECRET-KEY-…`
 * line. Returns `null` if the item is missing or the key can't be extracted.
 */
export async function gitopsReadProjectAgeKey(
  full: string
): Promise<string | null> {
  try {
    const blob = await opGetValue(
      `${full}/${SOPS_KEY_SECRET_NAME}`,
      externalSecretGetVaultName(false)
    );
    return gitopsExtractAgeSecretKey(blob);
  } catch {
    return null;
  }
}

export interface SopsKeysBundle {
  bundle: string;
  included: string[];
  skipped: string[];
}

/**
 * Assemble the in-cluster `sops-age` bundle: the current repo's own key plus
 * every registered Project's key (discovered from `tenants/*.yaml`), each
 * pulled from 1Password and concatenated. Projects whose key is missing are
 * skipped (warned), never fatal.
 */
export async function gitopsBuildSopsKeysBundle(opts: {
  repoRoot: string;
}): Promise<SopsKeysBundle> {
  // Always include the current (platform) repo so the repo-server can decrypt
  // its own secrets, then each registered Project repo.
  const self = await gitGetGitHubNamespace();
  const fulls: string[] = [self.full];

  const docs = await gitopsReadTenantDocs(opts.repoRoot);
  for (const url of gitopsDiscoverRepoUrlsFromTenants(docs)) {
    const ns = gitParseGitHubUrl(url);
    if (ns && !fulls.includes(ns.full)) fulls.push(ns.full);
  }

  await warmupVaultCache(externalSecretGetVaultName(false));

  const keys: string[] = [];
  const included: string[] = [];
  const skipped: string[] = [];
  for (const full of fulls) {
    const key = await gitopsReadProjectAgeKey(full);
    if (key) {
      keys.push(key);
      included.push(full);
    } else {
      skipped.push(full);
    }
  }

  return { bundle: gitopsAssembleBundle(keys), included, skipped };
}

/**
 * Write `bundle` to a 0600 temp file, run `fn` with its path, and always
 * remove it afterwards. The concatenated key material never persists on disk.
 */
export async function gitopsWithTempKeysFile<T>(
  bundle: string,
  fn: (filePath: string) => Promise<T>
): Promise<T> {
  const tmp = await Deno.makeTempFile({
    prefix: "sops-age-",
    suffix: ".txt",
  });
  try {
    await Deno.writeTextFile(tmp, bundle);
    await Deno.chmod(tmp, 0o600);
    return await fn(tmp);
  } finally {
    await Deno.remove(tmp).catch(() => {});
  }
}

/**
 * `kubectl create <args> --dry-run=client -o yaml | kubectl apply -f -`.
 * Server-side apply of a client-rendered manifest (idempotent create/update).
 */
async function kubectlCreateApply(createArgs: string[]): Promise<void> {
  await $`kubectl ${createArgs}`.pipe($`kubectl apply -f -`);
}

export async function gitopsKubectlApplyNamespace(
  namespace: string
): Promise<void> {
  await kubectlCreateApply(gitopsKubectlCreateNamespaceArgs(namespace));
}

export async function gitopsKubectlCreateGenericSecretFromFile(opts: {
  name: string;
  namespace: string;
  fileKey: string;
  filePath: string;
}): Promise<void> {
  await kubectlCreateApply(gitopsKubectlGenericSecretArgs(opts));
}

export async function gitopsKubectlCreateDockerRegistrySecret(opts: {
  name: string;
  namespace: string;
  server: string;
  username: string;
  password: string;
}): Promise<void> {
  await kubectlCreateApply(gitopsKubectlDockerRegistrySecretArgs(opts));
}
