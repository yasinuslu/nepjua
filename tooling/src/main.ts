import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { generate } from "./commands/generate/index.ts";

console.log("test");

await new Promise((resolve) => setTimeout(resolve, 1000));

console.log("testtttt");

// await new Command().command("generate", generate).parse(Deno.args);
