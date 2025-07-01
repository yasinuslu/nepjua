import $ from "@david/dax";

type OpVault = {
  id: string;
  name: string;
  content_version: number;
  created_at: string;
  updated_at: string;
  items: number;
};

type OpItem = {
  id: string;
  title: string;
  version: number;
  vault: {
    id: string;
    name: string;
  };
  category: string;
  sections?: OpSection[];
  fields?: OpField[];
};

type OpSection = {
  id: string;
  label: string;
};

type OpField = {
  id: string;
  type: string;
  purpose?: string;
  label: string;
  value?: string;
  reference?: string;
};

export async function opListVaults() {
  const vaults: OpVault[] = await $`op vault list --format=json`
    .stdout("piped")
    .then((r) => r.stdoutJson);

  return vaults;
}

export async function opListItems(vault: string): Promise<OpItem[]> {
  try {
    const items: OpItem[] = await $`op item list --vault=${vault} --format=json`
      .stdout("piped")
      .then((r) => r.stdoutJson);
    return items;
  } catch (error) {
    throw new Error(
      `Failed to list items in vault "${vault}": ${
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
    const item: OpItem =
      await $`op item get ${itemName} --vault=${vault} --format=json`
        .stdout("piped")
        .then((r) => r.stdoutJson);
    return item;
  } catch (error) {
    throw new Error(
      `Failed to get item "${itemName}" from vault "${vault}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opGetField(
  itemName: string,
  fieldName: string,
  vault: string
): Promise<string> {
  try {
    const value: string =
      await $`op item get ${itemName} --vault=${vault} --fields=${fieldName} --reveal`
        .stdout("piped")
        .text();
    return value.trim();
  } catch (error) {
    throw new Error(
      `Failed to get field "${fieldName}" from item "${itemName}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function opSetField(
  itemName: string,
  fieldName: string,
  value: string,
  vault: string
): Promise<void> {
  try {
    await $`op item edit ${itemName} --vault=${vault} ${fieldName}=${value}`;
  } catch (error) {
    // For 1Password CLI errors, we just need to check the exit code
    // The actual error message goes to stderr which we see in console
    throw new Error(`ITEM_OPERATION_FAILED: ${itemName}`);
  }
}

export async function opCreateItem(
  itemName: string,
  vault: string,
  fields: Record<string, string> = {}
): Promise<void> {
  try {
    const fieldArgs = Object.entries(fields).flatMap(([key, value]) => [
      `${key}[text]=${value}`,
    ]);

    await $`op item create --category="Secure Note" --title=${itemName} --vault=${vault} ${fieldArgs}`;
  } catch (error) {
    throw new Error(
      `Failed to create item "${itemName}": ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

export async function vaultOptionComplete() {
  const vaults = await opListVaults();
  return vaults.map((v) => v.name);
}
