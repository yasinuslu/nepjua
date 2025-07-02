import { gitGetGitHubNamespace, gitIsRepository } from "./git.ts";
import {
  opCreateItem,
  opDeleteItem,
  opGetField,
  opGetItem,
  opListItems,
  opSetField,
} from "./op.ts";

const REPO_VAULT_NAME = "Nepjua Automation";
const GLOBAL_VAULT_NAME = "Nepjua Automation Global";

export interface SecretPath {
  secretName: string;
  fieldName: string;
}

export interface ArchiveMetadata {
  archivedAt: string;
  archivedReason: string;
  originalCreatedAt?: string;
  repository: string;
}

export interface ArchiveResult {
  archivePath: string;
  originalPath: string;
}

export async function getNamespace(isGlobal: boolean): Promise<string> {
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

export function getVaultName(isGlobal: boolean): string {
  return isGlobal ? GLOBAL_VAULT_NAME : REPO_VAULT_NAME;
}

export function parseSecretPath(path: string): SecretPath {
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

export function getFullSecretName(
  secretName: string,
  namespace: string
): string {
  if (namespace === "") {
    // Global secrets
    return secretName;
  }
  return `${namespace}/${secretName}`;
}

export function parseFullSecretName(
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

function generateArchiveTimestamp(): string {
  return new Date().toISOString().replace(/[:.]/g, "-");
}

function getArchivePath(originalPath: string, namespace: string): string {
  const timestamp = generateArchiveTimestamp();
  const archiveSecretName = `archive/${originalPath}/${timestamp}`;
  return getFullSecretName(archiveSecretName, namespace);
}

export async function listSecretNames(isGlobal: boolean): Promise<string[]> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);

  // Fast: Only get item titles, no field access
  const items = await opListItems(vaultName);

  const secretNames: string[] = [];

  for (const item of items) {
    const secretName = parseFullSecretName(item.title, namespace);
    if (secretName !== null && !secretName.startsWith("archive/")) {
      secretNames.push(secretName);
    }
  }

  return secretNames.sort();
}

export async function listSecretFields(
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

export async function getSecret(
  path: string,
  isGlobal: boolean
): Promise<string> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const { secretName, fieldName } = parseSecretPath(path);
  const fullSecretName = getFullSecretName(secretName, namespace);

  return await opGetField(fullSecretName, fieldName, vaultName);
}

export async function setSecret(
  path: string,
  value: string,
  isGlobal: boolean
): Promise<void> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const { secretName, fieldName } = parseSecretPath(path);
  const fullSecretName = getFullSecretName(secretName, namespace);

  try {
    // Try to set the field (this will fail if item doesn't exist)
    await opSetField(fullSecretName, fieldName, value, vaultName);
  } catch (error) {
    // If item doesn't exist, create it
    if (
      error instanceof Error &&
      error.message.includes("ITEM_OPERATION_FAILED:")
    ) {
      await opCreateItem(fullSecretName, vaultName, {
        [fieldName]: value,
      });
    } else {
      throw error;
    }
  }
}

export async function archiveSecret(
  path: string,
  reason: string,
  isGlobal: boolean
): Promise<ArchiveResult> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);
  const { secretName, fieldName } = parseSecretPath(path);
  const fullSecretName = getFullSecretName(secretName, namespace);

  // Get the existing item with all its fields
  const existingItem = await opGetItem(fullSecretName, vaultName);

  // Prepare archive metadata
  const archiveMetadata: ArchiveMetadata = {
    archivedAt: new Date().toISOString(),
    archivedReason: reason,
    repository: namespace || "global",
  };

  // Try to extract original creation date if available
  if (existingItem.fields) {
    const createdAtField = existingItem.fields.find(
      (f) => f.label === "createdAt"
    );
    if (createdAtField?.value) {
      archiveMetadata.originalCreatedAt = createdAtField.value;
    }
  }

  // Create archive item with all original fields plus metadata
  const archivePath = getArchivePath(secretName, namespace);
  const archiveFields: Record<string, string> = {};

  // Copy all original fields
  if (existingItem.fields) {
    for (const field of existingItem.fields) {
      if (field.label && field.value !== undefined) {
        archiveFields[field.label] = field.value;
      }
    }
  }

  // Add archive metadata
  Object.entries(archiveMetadata).forEach(([key, value]) => {
    archiveFields[key] = value;
  });

  // Create the archive
  await opCreateItem(archivePath, vaultName, archiveFields);

  // Verify archive was created successfully
  await opGetItem(archivePath, vaultName);

  // Delete the original
  await opDeleteItem(fullSecretName, vaultName);

  return {
    archivePath,
    originalPath: fullSecretName,
  };
}

export async function restoreSecret(
  archivePath: string,
  isGlobal: boolean
): Promise<string> {
  const namespace = await getNamespace(isGlobal);
  const vaultName = getVaultName(isGlobal);

  // Add "archive/" prefix if not already present
  const prefixedArchivePath = archivePath.startsWith("archive/")
    ? archivePath
    : `archive/${archivePath}`;

  const fullArchivePath = getFullSecretName(prefixedArchivePath, namespace);

  // Get the archived item
  const archivedItem = await opGetItem(fullArchivePath, vaultName);

  if (!archivedItem.fields) {
    throw new Error("Archive item has no fields to restore");
  }

  // Extract original fields (exclude archive metadata)
  const originalFields: Record<string, string> = {};
  const metadataFields = new Set([
    "archivedAt",
    "archivedReason",
    "originalCreatedAt",
    "repository",
  ]);

  for (const field of archivedItem.fields) {
    if (
      field.label &&
      field.value !== undefined &&
      !metadataFields.has(field.label)
    ) {
      originalFields[field.label] = field.value;
    }
  }

  // Determine original secret name from archive path
  // archive/original/path/timestamp → original/path
  const archiveSecretName = parseFullSecretName(fullArchivePath, namespace);
  if (!archiveSecretName?.startsWith("archive/")) {
    throw new Error("Invalid archive path format");
  }

  const pathParts = archiveSecretName.slice("archive/".length).split("/");
  const timestamp = pathParts.pop(); // Remove timestamp
  const originalSecretName = pathParts.join("/");
  const originalFullName = getFullSecretName(originalSecretName, namespace);

  // Check if original already exists
  try {
    await opGetItem(originalFullName, vaultName);
    throw new Error(
      `Secret already exists at original path: ${originalSecretName}`
    );
  } catch (error) {
    // Good, original doesn't exist, we can restore
    if (
      !(error instanceof Error) ||
      !error.message.includes("Failed to get item")
    ) {
      throw error;
    }
  }

  // Create restored item
  await opCreateItem(originalFullName, vaultName, originalFields);

  // Verify restoration
  await opGetItem(originalFullName, vaultName);

  return originalFullName;
}

export async function listArchives(
  pathPrefix?: string,
  isGlobal?: boolean
): Promise<string[]> {
  const namespace = await getNamespace(isGlobal || false);
  const vaultName = getVaultName(isGlobal || false);

  const items = await opListItems(vaultName);
  const archives: string[] = [];

  for (const item of items) {
    const secretName = parseFullSecretName(item.title, namespace);
    if (secretName?.startsWith("archive/")) {
      const archiveName = secretName.slice("archive/".length);

      if (!pathPrefix || archiveName.startsWith(pathPrefix)) {
        archives.push(archiveName);
      }
    }
  }

  return archives.sort();
}
