import { Command } from "@cliffy/command";
import { getGitHubNamespace, isGitRepository } from "../lib/git.ts";
import {
  opCreateItem,
  opGetField,
  opGetItem,
  opListItems,
  opSetField,
} from "../lib/op.ts";

const REPO_VAULT_NAME = "Nepjua Automation";
const GLOBAL_VAULT_NAME = "Nepjua Automation Global";

interface SecretPath {
  secretName: string;
  fieldName: string;
}

async function getNamespace(isGlobal: boolean): Promise<string> {
  if (isGlobal) {
    return ""; // Global secrets have no namespace
  }

  if (!(await isGitRepository())) {
    throw new Error(
      "Not in a git repository. Use --global flag for global secrets."
    );
  }
  const namespace = await getGitHubNamespace();
  return namespace.full;
}

function getVaultName(isGlobal: boolean): string {
  return isGlobal ? GLOBAL_VAULT_NAME : REPO_VAULT_NAME;
}

function parseSecretPath(path: string): SecretPath {
  const parts = path.split("/");
  if (parts.length === 1) {
    // Simple key like "github-token" → main[github-token]
    return {
      secretName: "main",
      fieldName: parts[0],
    };
  } else {
    // Path like "db/host" → db[host]
    const fieldName = parts.pop()!;
    const secretName = parts.join("/");
    return {
      secretName,
      fieldName,
    };
  }
}

function getFullSecretName(secretName: string, namespace: string): string {
  if (namespace === "") {
    // Global secrets
    return secretName;
  }
  return `${namespace}/${secretName}`;
}

function parseFullSecretName(
  fullName: string,
  namespace: string
): string | null {
  if (namespace === "") {
    // Global secrets have no namespace prefix
    return fullName;
  }

  const prefix = `${namespace}/`;
  if (fullName.startsWith(prefix)) {
    return fullName.slice(prefix.length);
  }
  return null;
}

async function listAllSecretPaths(isGlobal: boolean): Promise<string[]> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const items = await opListItems(vaultName);

  const paths: string[] = [];

  for (const item of items) {
    const secretName = parseFullSecretName(item.title, namespace);
    if (secretName === null) continue;

    try {
      // Get the full item details to see all fields
      const fullItem = await opGetItem(item.title, vaultName);

      if (fullItem.fields) {
        for (const field of fullItem.fields) {
          if (field.label && field.value !== undefined) {
            if (secretName === "main") {
              // main[field] → just show field
              paths.push(field.label);
            } else {
              // secret[field] → show secret/field
              paths.push(`${secretName}/${field.label}`);
            }
          }
        }
      }
    } catch (error) {
      // Skip items we can't read
      console.error(`Warning: Could not read fields from ${item.title}`);
    }
  }

  return paths.sort();
}

export const secretCmd = new Command()
  .name("secret")
  .description("Path-based secret management with 1Password")
  .command(
    "ls",
    new Command()
      .description("List all secret paths (recursive, shows all fields)")
      .option(
        "-g, --global",
        "List global secrets instead of repository secrets"
      )
      .action(async (options: { global?: boolean }) => {
        try {
          const isGlobal = options.global || false;
          const paths = await listAllSecretPaths(isGlobal);

          if (paths.length === 0) {
            const scope = isGlobal ? "global" : await getNamespace(false);
            console.log(`No secrets found for ${scope}`);
          } else {
            paths.forEach((path) => console.log(path));
          }
        } catch (error) {
          console.error(
            `❌ Error: ${
              error instanceof Error ? error.message : String(error)
            }`
          );
          Deno.exit(1);
        }
      })
  )
  .command(
    "get",
    new Command()
      .description("Get a secret value by path")
      .arguments("<path:string>")
      .option(
        "-g, --global",
        "Get from global secrets instead of repository secrets"
      )
      .action(async (options: { global?: boolean }, path: string) => {
        try {
          const isGlobal = options.global || false;
          const namespace = await getNamespace(isGlobal);
          const vaultName = getVaultName(isGlobal);
          const { secretName, fieldName } = parseSecretPath(path);
          const fullSecretName = getFullSecretName(secretName, namespace);

          const value = await opGetField(fullSecretName, fieldName, vaultName);
          console.log(value);
        } catch (error) {
          console.error(
            `❌ Error: ${
              error instanceof Error ? error.message : String(error)
            }`
          );
          Deno.exit(1);
        }
      })
  )
  .command(
    "set",
    new Command()
      .description("Set a secret value by path")
      .arguments("<path:string> <value:string>")
      .option(
        "-g, --global",
        "Set in global secrets instead of repository secrets"
      )
      .action(
        async (options: { global?: boolean }, path: string, value: string) => {
          try {
            const isGlobal = options.global || false;
            const namespace = await getNamespace(isGlobal);
            const vaultName = getVaultName(isGlobal);
            const { secretName, fieldName } = parseSecretPath(path);
            const fullSecretName = getFullSecretName(secretName, namespace);

            try {
              // Try to set the field (this will fail if item doesn't exist)
              await opSetField(fullSecretName, fieldName, value, vaultName);
              console.log(`✅ Set ${path}`);
            } catch (error) {
              // If item doesn't exist, create it
              if (
                error instanceof Error &&
                error.message.includes("ITEM_OPERATION_FAILED:")
              ) {
                console.log(`Creating new secret: ${secretName}`);
                await opCreateItem(fullSecretName, vaultName, {
                  [fieldName]: value,
                });
                console.log(`✅ Created ${path}`);
              } else {
                throw error;
              }
            }
          } catch (error) {
            console.error(
              `❌ Error: ${
                error instanceof Error ? error.message : String(error)
              }`
            );
            Deno.exit(1);
          }
        }
      )
  )
  .reset()
  .action(() => secretCmd.showHelp());
