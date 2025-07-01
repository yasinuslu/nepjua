import { Command } from "@cliffy/command";
import {
  archiveSecret,
  getSecret,
  listArchives,
  listSecretFields,
  listSecretNames,
  restoreSecret,
  setSecret,
} from "../lib/secret.ts";

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
              const scope = isGlobal ? "global" : "repository";
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
          const value = await getSecret(path, isGlobal);
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
            await setSecret(path, value, isGlobal);
            console.log(`✅ Set ${path}`);
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
  .command(
    "archive",
    new Command()
      .description("Archive a secret (move to timestamped archive)")
      .arguments("<path:string>")
      .option(
        "-g, --global",
        "Archive from global secrets instead of repository secrets"
      )
      .option("-r, --reason <reason:string>", "Reason for archiving", {
        default: "manual",
      })
      .action(
        async (
          options: { global?: boolean; reason?: string },
          path: string
        ) => {
          try {
            const isGlobal = options.global || false;
            const reason = options.reason || "manual";

            const result = await archiveSecret(path, reason, isGlobal);
            console.log(`✅ Archived ${path}`);
            console.log(`   Original: ${result.originalPath}`);
            console.log(`   Archive:  ${result.archivePath}`);
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
  .command(
    "restore",
    new Command()
      .description("Restore a secret from archive")
      .arguments("<archive-path:string>")
      .option(
        "-g, --global",
        "Restore from global archives instead of repository archives"
      )
      .action(async (options: { global?: boolean }, archivePath: string) => {
        try {
          const isGlobal = options.global || false;

          const restoredPath = await restoreSecret(archivePath, isGlobal);
          console.log(`✅ Restored from archive`);
          console.log(`   Archive:  ${archivePath}`);
          console.log(`   Restored: ${restoredPath}`);
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
    "list-archives",
    new Command()
      .description("List archived secrets")
      .arguments("[path-prefix:string]")
      .option(
        "-g, --global",
        "List global archives instead of repository archives"
      )
      .action(async (options: { global?: boolean }, pathPrefix?: string) => {
        try {
          const isGlobal = options.global || false;

          const archives = await listArchives(pathPrefix, isGlobal);

          if (archives.length === 0) {
            const scope = isGlobal ? "global" : "repository";
            const prefix = pathPrefix ? ` matching "${pathPrefix}"` : "";
            console.log(`No archived secrets found for ${scope}${prefix}`);
          } else {
            archives.forEach((archive) => console.log(archive));
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
  .reset()
  .action(() => secretCmd.showHelp());
