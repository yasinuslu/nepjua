import { $ } from "zx";

// Timeout for 1Password operations (in milliseconds)
const OP_TIMEOUT = 60000; // 60 seconds - much higher since manual commands work fine

// Create a dedicated zx context with timeout
const $$ = $({ timeout: OP_TIMEOUT });

// Base64 encoding/decoding utilities for handling multiline values
function encodeValue(value: string): string {
  const encoder = new TextEncoder();
  const data = encoder.encode(value);
  return btoa(String.fromCharCode(...data));
}

function decodeValue(encodedValue: string): string {
  try {
    const binaryString = atob(encodedValue);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    const decoder = new TextDecoder();
    return decoder.decode(bytes);
  } catch (error) {
    // If decoding fails, assume it's not base64 encoded (legacy data)
    return encodedValue;
  }
}

// Simple cache for item mappings per vault
interface VaultCache {
  nameToId: Map<string, string>;
  lastUpdated: number;
}

// Cache per vault: vault name -> VaultCache
const vaultCaches = new Map<string, VaultCache>();

function getVaultCache(vault: string): VaultCache {
  let cache = vaultCaches.get(vault);

  if (!cache) {
    cache = {
      nameToId: new Map(),
      lastUpdated: Date.now(),
    };
    vaultCaches.set(vault, cache);
  }

  return cache;
}

function getCachedItemId(vault: string, itemName: string): string | undefined {
  const cache = vaultCaches.get(vault);
  if (!cache) {
    return undefined;
  }
  return cache.nameToId.get(itemName);
}

function setCachedItemId(
  vault: string,
  itemName: string,
  itemId: string
): void {
  const cache = getVaultCache(vault);
  cache.nameToId.set(itemName, itemId);
}

// Function to pre-populate cache for a vault - call this at the start of commands
export async function warmupVaultCache(vault: string): Promise<OpItem[]> {
  const cache = vaultCaches.get(vault);
  if (!cache || cache.nameToId.size === 0) {
    // Cache is empty, populate it
    return await opListItems(vault);
  }
  // Cache already populated, return empty array as items aren't needed
  return [];
}

export interface OpVault {
  id: string;
  name: string;
  content_version: number;
  created_at: string;
  updated_at: string;
  items: number;
}

export interface OpItem {
  id: string;
  title: string;
  version: number;
  vault: {
    id: string;
    name: string;
  };
  category: string;
  state?: string;
  sections?: OpSection[];
  fields?: OpField[];
}

export interface OpSection {
  id: string;
  label: string;
}

export interface OpField {
  id: string;
  type: string;
  purpose?: string;
  label: string;
  value?: string;
  reference?: string;
}

export async function opListVaults() {
  try {
    const vaults: OpVault[] = await $$`op vault list --format json`.json<
      OpVault[]
    >();
    return vaults;
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw error;
  }
}

export async function opListItems(vault: string): Promise<OpItem[]> {
  try {
    const items = await $$`op item list --vault ${vault} --format json`.json<
      OpItem[]
    >();

    // Populate cache with item name -> ID mappings
    for (const item of items) {
      setCachedItemId(vault, item.title, item.id);
    }

    return items;
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to list items in vault "${vault}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

// Helper function to resolve item name to ID using cache
async function resolveItemId(itemName: string, vault: string): Promise<string> {
  // Check cache first
  const cachedId = getCachedItemId(vault, itemName);
  if (cachedId) {
    return cachedId;
  }

  // If itemName looks like an ID (UUID format), try using it directly
  if (/^[a-z0-9]{26}$/.test(itemName)) {
    try {
      const item =
        await $$`op item get ${itemName} --vault ${vault} --format json`.json<OpItem>();
      // Cache both the ID->ID mapping and name->ID mapping
      setCachedItemId(vault, itemName, item.id);
      setCachedItemId(vault, item.title, item.id);
      return item.id;
    } catch (error) {
      // Fall through to list-based resolution
    }
  }

  try {
    // Refresh cache by listing all items
    const items = await opListItems(vault);
    const foundItem = items.find((item) => item.title === itemName);
    if (foundItem) {
      return foundItem.id;
    }
    throw new Error(`Item "${itemName}" not found in vault "${vault}"`);
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to resolve item "${itemName}" in vault "${vault}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opGetItem(
  itemName: string,
  vault: string
): Promise<OpItem> {
  try {
    const itemId = await resolveItemId(itemName, vault);

    const item =
      await $$`op item get ${itemId} --vault ${vault} --format json`.json<OpItem>();

    // Update cache with the latest item info
    setCachedItemId(vault, item.title, item.id);

    return item;
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to get item "${itemName}" from vault "${vault}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opGetValue(
  itemName: string,
  vault: string
): Promise<string> {
  try {
    // Resolve item name to ID first
    const itemId = await resolveItemId(itemName, vault);

    const value =
      await $$`op item get ${itemId} --vault ${vault} --fields notesPlain --reveal`.text();
    let trimmedValue = value.trim();

    // Strip surrounding quotes that 1Password CLI adds to multi-line values
    if (trimmedValue.startsWith('"') && trimmedValue.endsWith('"')) {
      trimmedValue = trimmedValue.slice(1, -1);
    }

    // Decode from base64 (handles both new base64 and legacy plain text)
    return decodeValue(trimmedValue);
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to get value from item "${itemName}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opSetValue(
  itemName: string,
  value: string,
  vault: string
): Promise<void> {
  try {
    // Resolve item name to ID for edit operations
    const itemId = await resolveItemId(itemName, vault);
    // Encode value as base64 to avoid multiline/escaping issues
    const encodedValue = encodeValue(value);
    await $$`op item edit ${itemId} --vault ${vault} notesPlain=${encodedValue}`;
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    // Check if this is a "not found" error to maintain existing behavior
    if (
      error instanceof Error &&
      (error.message.includes("not found") ||
        error.message.includes("isn't an item"))
    ) {
      throw new Error(`ITEM_OPERATION_FAILED: ${itemName}`);
    }
    throw new Error(`ITEM_OPERATION_FAILED: ${itemName}`);
  }
}

export async function opCreateItem(
  itemName: string,
  vault: string,
  value: string
): Promise<void> {
  try {
    // Encode value as base64 to avoid multiline/escaping issues
    const encodedValue = encodeValue(value);
    const result =
      await $$`op item create --category=Secure Note --title=${itemName} --vault=${vault} notesPlain=${encodedValue} --format json`.json<OpItem>();

    // Cache the newly created item
    setCachedItemId(vault, itemName, result.id);
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to create item "${itemName}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opArchiveItem(
  itemName: string,
  vault: string
): Promise<void> {
  try {
    // Resolve item name to ID for archive operations
    const itemId = await resolveItemId(itemName, vault);
    await $$`op item delete ${itemId} --archive --vault=${vault}`;
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to archive item "${itemName}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opListArchivedItems(vault: string): Promise<OpItem[]> {
  try {
    const items =
      await $$`op item list --vault ${vault} --format json --include-archive`.json<
        OpItem[]
      >();
    // Filter to only archived items (1Password includes both active and archived with --include-archive)
    return items.filter((item) => item.state === "ARCHIVED");
  } catch (error) {
    if (
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("exit code: 143"))
    ) {
      throw new Error(
        `1Password operation timed out after ${OP_TIMEOUT / 1000} seconds`
      );
    }
    throw new Error(
      `Failed to list archived items in vault "${vault}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opVaultOptionComplete() {
  const vaults = await opListVaults();
  return vaults.map((v) => v.name);
}
