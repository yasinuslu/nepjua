import { Command } from "@cliffy/command";
import { CompletionsCommand } from "@cliffy/command/completions";
import { certsCmd } from "./commands/certs.ts";
import { secretCmd } from "./commands/secret.ts";
import { sopsCommand } from "./commands/sops.ts";
import { utilCmd } from "./commands/util.ts";

const cmd = new Command()
  .name("nep")
  .version("0.0.1")
  .description("A Command Line Tool for Automating my tasks")
  .command("completions", new CompletionsCommand())
  .command("sops", sopsCommand)
  .command("certs", certsCmd)
  .command("util", utilCmd)
  .command("secret", secretCmd)
  .reset()
  .action(() => cmd.showHelp());

await cmd.parse(Deno.args);
