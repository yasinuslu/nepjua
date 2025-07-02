import { $ } from "./$.ts";
import { ensureLinesInFile } from "./fs.ts";
import { archiveSecret, getSecret, setSecret } from "./secret.ts";

const SOPS_KEY_PATH = "SOPS/age-key";

export interface SopsBootstrapOptions {
  force?: boolean;
}

export interface SopsBootstrapResult {
  publicKey: string;
  configCreated: boolean;
  gitignoreUpdated: boolean;
  keyArchived: boolean;
}

export interface SopsSetupResult {
  keyPath: string;
  keyWritten: boolean;
}

export async function sopsBootstrap(
  options: SopsBootstrapOptions = {}
): Promise<SopsBootstrapResult> {
  const { force = false } = options;
  let keyArchived = false;

  // Check if .sops.yaml already exists
  try {
    await Deno.stat(".sops.yaml");
    if (!force) {
      throw new Error(".sops.yaml already exists. Use --force to override.");
    }
  } catch (error) {
    if (
      error instanceof Error &&
      error.message.includes(".sops.yaml already exists")
    ) {
      throw error;
    }
    // File doesn't exist, that's fine
  }

  // Check if SOPS AGE key already exists
  try {
    await getSecret(SOPS_KEY_PATH, false);
    if (!force) {
      throw new Error("SOPS AGE key already exists. Use --force to override.");
    }
    // Archive existing key
    await archiveSecret(SOPS_KEY_PATH, "Replaced by new bootstrap", false);
    keyArchived = true;
  } catch (error) {
    if (
      error instanceof Error &&
      error.message.includes("SOPS AGE key already exists")
    ) {
      throw error;
    }
    // Key doesn't exist, that's fine
  }

  // Generate new AGE key pair
  const keyOutput = await $`age-keygen`.text();

  // Extract public key from output
  const publicKeyMatch = keyOutput.match(/# public key: (age\w+)/);
  if (!publicKeyMatch) {
    throw new Error("Failed to extract public key from age-keygen output");
  }
  const publicKey = publicKeyMatch[1];

  // Store private key
  await setSecret(SOPS_KEY_PATH, keyOutput.trim(), false);

  // Create .sops.yaml
  const sopsConfig = `creation_rules:
  - age: ${publicKey}
`;
  await Deno.writeTextFile(".sops.yaml", sopsConfig);

  await ensureLinesInFile(".gitignore", [
    "# SOPS",
    ".sops/",
    "*.age",
    ".tmp",
    "*.enc.tmp.*",
  ]);

  return {
    publicKey,
    configCreated: true,
    gitignoreUpdated: true,
    keyArchived,
  };
}

export async function sopsSetup(): Promise<SopsSetupResult> {
  // Get AGE key
  let keyData;
  try {
    keyData = await getSecret(SOPS_KEY_PATH, false);
  } catch {
    throw new Error(
      "Failed to retrieve SOPS AGE key. Run 'nep sops bootstrap' first to set up SOPS"
    );
  }

  // Create .sops directory
  await Deno.mkdir(".sops", { recursive: true });

  // Write key to file
  const keyPath = ".sops/age-key.txt";
  await Deno.writeTextFile(keyPath, keyData);
  await Deno.chmod(keyPath, 0o600);

  await ensureLinesInFile(".gitignore", [
    "# SOPS",
    ".sops/",
    "*.age",
    ".tmp",
    "*.enc.tmp.*",
  ]);

  return {
    keyPath,
    keyWritten: true,
  };
}
