import { Command } from "@cliffy/command";
import { sopsBootstrap, sopsSetup } from "../lib/sops.ts";

export const sopsCommand = new Command()
  .name("sops")
  .description("Manage SOPS encryption setup")
  .command(
    "bootstrap",
    "Initialize SOPS with AGE encryption for this repository"
  )
  .option("--force", "Force bootstrap even if SOPS is already configured")
  .action(async ({ force }) => {
    try {
      console.log("🔄 Starting SOPS bootstrap...");

      const result = await sopsBootstrap({ force });

      if (result.keyArchived) {
        console.log("📦 Archived existing SOPS AGE key");
      }
      console.log("🔑 Generated new AGE key pair");
      console.log("🔐 Stored private key");
      console.log("📝 Created .sops.yaml configuration");

      console.log("✅ SOPS bootstrap complete!");
      console.log(`   Public key: ${result.publicKey}`);
    } catch (error) {
      console.error(
        `❌ ${error instanceof Error ? error.message : String(error)}`
      );
      Deno.exit(1);
    }
  })
  .reset()
  .command("setup", "Set up SOPS for an existing repository")
  .action(async () => {
    try {
      console.log("🔄 Setting up SOPS...");

      const result = await sopsSetup();

      console.log("🔑 Retrieved AGE key");
      console.log("✅ SOPS setup complete!");
      console.log(`   AGE key written to ${result.keyPath}`);
      console.log(
        "   You can now use: export SOPS_AGE_KEY_FILE=.sops/age-key.txt"
      );
    } catch (error) {
      console.error(
        `❌ ${error instanceof Error ? error.message : String(error)}`
      );
      Deno.exit(1);
    }
  });
