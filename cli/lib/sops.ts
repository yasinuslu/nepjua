import { stringify } from "@std/yaml";
import path from "node:path";
import { $ } from "zx";
import { externalSecretGet, setSecret } from "./external-secret.ts";
import { ensureLinesInFile } from "./fs.ts";
import { gitFindRoot } from "./git.ts";

const SOPS_KEY_SECRET_NAME = "SOPS/age-key";

export interface SopsBootstrapOptions {
  force?: boolean;
}

export interface SopsBootstrapResult {
  publicKey: string;
  configCreated: boolean;
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
  const gitRoot = await gitFindRoot();

  // Check if .sops.yaml already exists
  try {
    await Deno.stat(path.join(gitRoot, ".sops.yaml"));
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
    await externalSecretGet(SOPS_KEY_SECRET_NAME, false);
    if (!force) {
      throw new Error("SOPS AGE key already exists. Use --force to override.");
    }
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

  // Store private key (this will update existing or create new)
  await setSecret(SOPS_KEY_SECRET_NAME, keyOutput.trim(), false);

  // Create .sops.yaml
  const sopsConfig = stringify(
    {
      stores: {
        yaml: {
          indent: 2,
        },
      },
      creation_rules: [
        {
          path_regex: ".*\\.enc\\.(yaml|yml|json|env)$",
          unencrypted_regex: "^(apiVersion|metadata|kind|type|immutable)$",
          age: publicKey,
        },
      ],
    },
    {
      indent: 2,
    }
  );
  await Deno.writeTextFile(path.join(gitRoot, ".sops.yaml"), sopsConfig);

  await sopsSetup();

  return {
    publicKey,
    configCreated: true,
    keyArchived: false,
  };
}

export async function sopsSetup(): Promise<SopsSetupResult> {
  // Get AGE key
  let keyData;
  try {
    keyData = await externalSecretGet(SOPS_KEY_SECRET_NAME, false);
  } catch {
    throw new Error(
      "Failed to retrieve SOPS AGE key. Run 'nep sops bootstrap' first to set up SOPS"
    );
  }

  const gitRoot = await gitFindRoot();

  // Extract only the private key line for the identity file
  const privateKeyMatch = keyData.match(/AGE-SECRET-KEY-[A-Z0-9]+/);
  if (!privateKeyMatch) {
    throw new Error("Failed to extract AGE private key from stored data");
  }
  const privateKey = privateKeyMatch[0];

  // Use global SOPS directory instead of project-relative
  const homeDir = Deno.env.get("HOME");
  if (!homeDir) {
    throw new Error("HOME environment variable not set");
  }
  const globalSopsDir = path.join(homeDir, ".config", "sops");

  // Create global .config/sops directory
  await Deno.mkdir(globalSopsDir, { recursive: true });

  // Write key to global location
  const keyPath = path.join(globalSopsDir, "age-key.txt");
  await Deno.writeTextFile(keyPath, privateKey);
  await Deno.chmod(keyPath, 0o600);

  // Also place key in root location for activation phase (requires sudo)
  const rootSopsDir = "/var/root/.config/sops";
  const rootKeyPath = path.join(rootSopsDir, "age-key.txt");

  try {
    console.log("Setting up age key for root user...");
    await $`sudo mkdir -p ${rootSopsDir}`;
    await $`sudo cp ${keyPath} ${rootKeyPath}`;
    await $`sudo chmod 600 ${rootKeyPath}`;
    await $`sudo chown root:wheel ${rootKeyPath}`;
    console.log(`✅ Age key installed for root at ${rootKeyPath}`);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.warn(`⚠️  Failed to setup root key: ${errorMessage}`);
    console.warn(
      "You may need to run 'sudo darwin-rebuild switch' for initial setup"
    );
  }

  // Still create local .sops directory for any local temp files
  await Deno.mkdir(path.join(gitRoot, ".sops"), { recursive: true });

  await ensureLinesInFile(path.join(gitRoot, ".gitignore"), [
    "# SOPS",
    ".sops/",
    "*.age",
    ".tmp",
    "*.enc.tmp.*",
  ]);

  await ensureLinesInFile(
    path.join(gitRoot, ".envrc"),
    [
      "watch_file .env",
      "if [ -f .env ]; then",
      "  set -a",
      "  source .env",
      "  set +a",
      "fi",
    ],
    { mode: "prepend" }
  );

  await ensureLinesInFile(path.join(gitRoot, ".env"), [
    `SOPS_AGE_KEY_FILE="${keyPath}"`,
  ]);

  return {
    keyPath,
    keyWritten: true,
  };
}

export function sopsReadAndDecrypt(path: string) {
  return $`sops --decrypt ${path}`.text();
}
