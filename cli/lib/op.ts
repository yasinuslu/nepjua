import $ from "@david/dax";

type OpVault = {
  id: string;
  name: string;
  content_version: number;
  created_at: string;
  updated_at: string;
  items: number;
};

export async function opListVaults() {
  const vaults: OpVault[] = await $`op vault list --format=json`
    .stdout("piped")
    .then((r) => r.stdoutJson);

  return vaults;
}

export async function opReadItem(itemName: string) {
  throw new Error("Not implemented");
}

export async function opWriteItem(itemName: string) {
  throw new Error("Not implemented");
}

export async function vaultOptionComplete() {
  const vaults = await opListVaults();
  return vaults.map((v) => v.name);
}
