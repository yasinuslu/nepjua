import { Command } from "@cliffy/command";
import { gitGetGitHubNamespace, gitIsRepository } from "../lib/git.ts";
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

  if (!(await gitIsRepository())) {
    throw new Error(
      "Not in a git repository. Use --global flag for global secrets."
    );
  }
  const namespace = await gitGetGitHubNamespace();
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

async function listSecretNames(isGlobal: boolean): Promise<string[]> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);

  // Fast: Only get item titles, no field access
  const items = await opListItems(vaultName);

  const secretNames: string[] = [];

  for (const item of items) {
    const secretName = parseFullSecretName(item.title, namespace);
    if (secretName !== null) {
      secretNames.push(secretName);
    }
  }

  return secretNames.sort();
}

async function listSecretFields(
  secretName: string,
  isGlobal: boolean
): Promise<string[]> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const fullSecretName = getFullSecretName(secretName, namespace);

  // Targeted: Get specific item fields
  const item = await opGetItem(fullSecretName, vaultName);

  const fieldNames: string[] = [];

  if (item.fields) {
    for (const field of item.fields) {
      if (field.label && field.value !== undefined) {
        fieldNames.push(field.label);
      }
    }
  }

  return fieldNames.sort();
}

export const secretCmd = new Command()
  .name("secret")
  .description("Path-based secret management with 1Password")
  .command(
    "ls",
    new Command()
      .description("List secret names, or fields for a specific secret")
      .arguments("[secret-name:string]")
      .option(
        "-g, --global",
        "List global secrets instead of repository secrets"
      )
      .action(async (options: { global?: boolean }, secretName?: string) => {
        try {
          const isGlobal = options.global || false;

          if (secretName) {
            // Show fields for specific secret
            const fields = await listSecretFields(secretName, isGlobal);

            if (fields.length === 0) {
              console.log(`No fields found in secret: ${secretName}`);
            } else {
              fields.forEach((field) => {
                if (secretName === "main") {
                  // main[field] → show as just field name
                  console.log(field);
                } else {
                  // secret[field] → show as secret/field
                  console.log(`${secretName}/${field}`);
                }
              });
            }
          } else {
            // Show all secret names only
            const secrets = await listSecretNames(isGlobal);

            if (secrets.length === 0) {
              const scope = isGlobal ? "global" : await getNamespace(false);
              console.log(`No secrets found for ${scope}`);
            } else {
              secrets.forEach((secret) => console.log(secret));
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
