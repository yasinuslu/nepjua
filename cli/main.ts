import { Command } from "@cliffy/command";
import { CompletionsCommand } from "@cliffy/command/completions";
import { sopsCmd } from "./sops.ts";

const cmd = new Command()
  .name("nep")
  .version("0.0.1")
  .description("A Command Line Tool for Automating my tasks")
  .command("completions", new CompletionsCommand())
  .command("sops", sopsCmd)
  .reset()
  .action(() => cmd.showHelp());

await cmd.parse(Deno.args);
