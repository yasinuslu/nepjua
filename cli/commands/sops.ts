import { Command } from "@cliffy/command";
import { opVaultOptionComplete } from "../lib/op.ts";

async function setupSopsKey() {
  console.log();
}

async function generateSopsKey() {}

const keyCommand = new Command()
  .name("key")
  .description("SOPS key related tasks")
  .command("setup", "Setup SOPS key")
  .option("-v, --vault <vault:vault>", "Vault to use")
  .complete("vault", opVaultOptionComplete)
  .action(async (a, b) => {
    console.log(a, b);
  })
  .reset()
  .command("generate", "Generate a new SOPS key")
  .option("-v, --vault <vault:vault>", "Vault to use")
  .complete("vault", opVaultOptionComplete)
  .action(generateSopsKey)
  .action(() => keyCommand.showHelp());

export const sopsCmd = new Command()
  .name("sops")
  .description("SOPS related tasks")
  .command("key", keyCommand)
  .reset()
  .action(() => sopsCmd.showHelp());
