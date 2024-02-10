import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";

export const clone = new Command()
  .arguments("<source:string> [destination:string]")
  .description("Clone a repository into a newly created directory.")
  .action((options: any, source: string, destination?: string) => {
    console.log("clone command called");
  });
