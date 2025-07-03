import { Command } from "@cliffy/command";
import {
  externalSecretArchive,
  externalSecretGet,
  externalSecretList,
  setSecret,
} from "../lib/external-secret.ts";

export const secretCmd = new Command()
  .name("secret")
  .description("Path-based secret management with 1Password")
  .command(
    "ls",
    new Command()
      .description("List secret names")
      .option(
        "-g, --global",
        "List global secrets instead of repository secrets"
      )
      .action(async (options: { global?: boolean }) => {
        try {
          const isGlobal = options.global || false;
          const secrets = await externalSecretList(isGlobal);

          if (secrets.length === 0) {
            const scope = isGlobal ? "global" : "repository";
            console.log(`No secrets found for ${scope}`);
          } else {
            secrets.forEach((secret) => console.log(secret));
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
          const value = await externalSecretGet(path, isGlobal);
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
      .description("Archive a secret using 1Password's native archiving")
      .arguments("<path:string>")
      .option("-g, --global", "Use the global vault", { default: false })
      .action(async (options: { global?: boolean }, path: string) => {
        try {
          const isGlobal = options.global || false;
          await externalSecretArchive(path, isGlobal);
          console.log(`✅ Archived ${path}`);
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
