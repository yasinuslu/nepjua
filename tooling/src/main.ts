import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { generate } from "./commands/generate/index.ts";

await new Command().command("generate", generate).parse(Deno.args);
