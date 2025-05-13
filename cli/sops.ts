import { Command } from "@cliffy/command";
import $ from "@david/dax";

async function writeTo1Password(key: string) {
  const password = await $.prompt("Enter the password to store in 1Password:");
  const itemName = await $.prompt("Enter the name of the item in 1Password:");
  const vaultName = await $.prompt("Enter the name of the vault in 1Password:");

  await $.exec("op", [
    "item",
    "create",
    `--title=${itemName}`,
    `--vault=${vaultName}`,
    `--password=${password}`,
    `--field=key=${key}`,
  ]);
}

async function readFrom1Password(itemName: string) {
  const item = await $.exec("op", ["item", "get", itemName, "--format=json"]);
  const parsedItem = JSON.parse(item);
  return parsedItem.fields.find((field) => field.label === "key").value;
}

async function setupSopsKey() {}

async function generateSopsKey() {}

export const sopsCmd = new Command()
  .name("sops")
  .description("SOPS related tasks")
  .command("key-setup", "Setup SOPS key")
  .action(setupSopsKey)
  .reset()
  .command("key-generate", "Generate a new SOPS key")
  .action(generateSopsKey);
