import { gitGetGitHubNamespace } from "./git.ts";
import {
  opArchiveItem,
  opCreateItem,
  opGetValue,
  opListArchivedItems,
  opListItems,
  opSetValue,
  warmupVaultCache,
} from "./op.ts";

const REPO_VAULT_NAME = "Nepjua Automation";
const GLOBAL_VAULT_NAME = "Nepjua-Global";

function getVaultName(isGlobal: boolean): string {
  return isGlobal ? GLOBAL_VAULT_NAME : REPO_VAULT_NAME;
}

async function getNamespace(isGlobal: boolean): Promise<string> {
  if (isGlobal) {
    return "global";
  }
  const namespace = await gitGetGitHubNamespace();
  return namespace.full;
}

function getFullSecretName(secretName: string, namespace: string): string {
  return `${namespace}/${secretName}`;
}

function parseFullSecretName(
  fullSecretName: string,
  namespace: string
): string | null {
  const prefix = `${namespace}/`;
  if (fullSecretName.startsWith(prefix)) {
    return fullSecretName.substring(prefix.length);
  }
  return null;
}

export async function listSecretNames(isGlobal: boolean): Promise<string[]> {
  const vaultName = getVaultName(isGlobal);
  const namespace = await getNamespace(isGlobal);

  // Warm up the cache for the vault
  const items = await warmupVaultCache(vaultName);

  const secrets: string[] = [];

  // Use the items from the warmup if available, otherwise list them
  const itemsToList = items.length > 0 ? items : await opListItems(vaultName);

  for (const item of itemsToList) {
    const secretName = parseFullSecretName(item.title, namespace);
    if (secretName !== null) {
      secrets.push(secretName);
    }
  }

  return secrets.sort();
}

export async function getSecret(
  path: string,
  isGlobal: boolean
): Promise<string> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const fullSecretName = getFullSecretName(path, namespace);

  // Warm up the cache before any operations
  await warmupVaultCache(vaultName);
  return await opGetValue(fullSecretName, vaultName);
}

export async function setSecret(
  path: string,
  value: string,
  isGlobal: boolean
) {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const fullSecretName = getFullSecretName(path, namespace);

  try {
    // Warm up the cache before any operations
    await warmupVaultCache(vaultName);
    await opSetValue(fullSecretName, value, vaultName);
  } catch (error) {
    if (
      error instanceof Error &&
      error.message.includes("ITEM_OPERATION_FAILED")
    ) {
      await opCreateItem(fullSecretName, vaultName, value);
    } else {
      throw error;
    }
  }
}

export interface ArchiveResult {
  itemName: string;
}

export async function archiveSecret(
  path: string,
  isGlobal: boolean
): Promise<ArchiveResult> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const fullSecretName = getFullSecretName(path, namespace);

  // Warm up the cache before any operations
  await warmupVaultCache(vaultName);

  // Use 1Password's native archive functionality
  await opArchiveItem(fullSecretName, vaultName);

  return {
    itemName: fullSecretName,
  };
}

export async function listArchivedSecrets(
  isGlobal: boolean
): Promise<string[]> {
  const vaultName = getVaultName(isGlobal);
  const namespace = await getNamespace(isGlobal);

  const archivedItems = await opListArchivedItems(vaultName);
  const archives: string[] = [];

  for (const item of archivedItems) {
    const secretName = parseFullSecretName(item.title, namespace);
    if (secretName !== null) {
      archives.push(secretName);
    }
  }

  return archives.sort();
}
