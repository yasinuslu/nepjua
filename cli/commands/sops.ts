import { Command } from "@cliffy/command";
import { $ } from "../lib/command.ts";
import { archiveSecret, getSecret, setSecret } from "../lib/secret.ts";

const SOPS_KEY_PATH = "SOPS/age-key";

export const sopsCommand = new Command()
  .name("sops")
  .description("Manage SOPS encryption setup")
  .command(
    "bootstrap",
    "Initialize SOPS with AGE encryption for this repository"
  )
  .option("--force", "Force bootstrap even if SOPS is already configured")
  .action(async ({ force }) => {
    // Check if .sops.yaml already exists
    try {
      await Deno.stat(".sops.yaml");
      if (!force) {
        console.error("❌ .sops.yaml already exists. Use --force to override.");
        Deno.exit(1);
      }
    } catch {
      // File doesn't exist, that's fine
    }

    // Check if SOPS AGE key already exists
    try {
      await getSecret(SOPS_KEY_PATH, false);
      if (!force) {
        console.error(
          "❌ SOPS AGE key already exists. Use --force to override."
        );
        Deno.exit(1);
      }
      // Archive existing key
      console.log("📦 Archiving existing SOPS AGE key...");
      await archiveSecret(SOPS_KEY_PATH, "Replaced by new bootstrap", false);
    } catch {
      // Key doesn't exist, that's fine
    }

    // Generate new AGE key pair
    console.log("🔑 Generating new AGE key pair...");
    const keyOutput = await $`age-keygen`.text();

    // Extract public key from output
    const publicKeyMatch = keyOutput.match(/# public key: (age\w+)/);
    if (!publicKeyMatch) {
      console.error("❌ Failed to extract public key from age-keygen output");
      Deno.exit(1);
    }
    const publicKey = publicKeyMatch[1];

    // Store private key
    console.log("🔐 Storing private key...");
    await setSecret(SOPS_KEY_PATH, keyOutput.trim(), false);

    // Create .sops.yaml
    console.log("📝 Creating .sops.yaml configuration...");
    const sopsConfig = `creation_rules:
  - age: ${publicKey}
`;
    await Deno.writeTextFile(".sops.yaml", sopsConfig);

    // Update .gitignore
    console.log("📝 Updating .gitignore...");
    const gitignoreContent = await Deno.readTextFile(".gitignore").catch(
      () => ""
    );
    if (!gitignoreContent.includes(".sops/")) {
      await Deno.writeTextFile(
        ".gitignore",
        gitignoreContent + "\n# SOPS\n.sops/\n*.age\n"
      );
    }

    console.log("✅ SOPS bootstrap complete!");
  })
  .reset()
  .command("setup", "Set up SOPS for an existing repository")
  .action(async () => {
    // Get AGE key
    console.log("🔑 Retrieving AGE key...");
    let keyData;
    try {
      keyData = await getSecret(SOPS_KEY_PATH, false);
    } catch {
      console.error("❌ Failed to retrieve SOPS AGE key");
      console.error("   Run 'nep sops bootstrap' first to set up SOPS");
      Deno.exit(1);
    }

    // Create .sops directory
    await Deno.mkdir(".sops", { recursive: true });

    // Write key to file
    const keyPath = ".sops/age-key.txt";
    await Deno.writeTextFile(keyPath, keyData);
    await Deno.chmod(keyPath, 0o600);

    console.log("✅ SOPS setup complete!");
    console.log("   AGE key written to .sops/age-key.txt");
    console.log(
      "   You can now use: export SOPS_AGE_KEY_FILE=.sops/age-key.txt"
    );
  });
