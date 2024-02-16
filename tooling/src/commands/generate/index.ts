import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { barrel } from "./plugins/barrel.ts";
import { parse } from "https://deno.land/std@0.207.0/yaml/mod.ts";

const readConfig = async (configPath: string) => {
  const file = await Deno.readTextFile(configPath);
  return parse(file);
};

export const generate = new Command()
  .description("Generate files using configuration files")
  .option("-c, --config <config:string>", "The optional configuration file")
  .arguments("[startDirectory:string]")
  .action(async (params) => {});
