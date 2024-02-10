import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { clone } from "./commands/create-tunnel.ts";

await new Command().command("clone", clone).parse(Deno.args);
