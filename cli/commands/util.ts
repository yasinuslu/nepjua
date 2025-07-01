import { Command } from "@cliffy/command";
import {
  gitFindRoot,
  gitGetGitHubNamespace,
  gitGetRemotes,
  gitIsRepository,
} from "../lib/git.ts";

export const utilCmd = new Command()
  .name("util")
  .description("General utilities for development workflows")
  .command(
    "namespace",
    new Command()
      .description(
        "Get the GitHub namespace (owner/repo) for the current repository"
      )
      .option("-v, --verbose", "Show detailed information about git remotes")
      .action(async (options: { verbose?: boolean }) => {
        try {
          if (!(await gitIsRepository())) {
            console.error("❌ Not in a git repository");
            Deno.exit(1);
          }

          if (options.verbose) {
            console.log("📂 Repository information:");
            console.log(`   Root: ${await gitFindRoot()}`);
            console.log("\n🔗 Git remotes:");

            const remotes = await gitGetRemotes();
            for (const remote of remotes) {
              console.log(`   ${remote.name} (${remote.type}): ${remote.url}`);
            }
            console.log();
          }

          const namespace = await gitGetGitHubNamespace();

          if (options.verbose) {
            console.log("🎯 GitHub namespace:");
            console.log(`   Owner: ${namespace.owner}`);
            console.log(`   Repository: ${namespace.repo}`);
            console.log(`   Full: ${namespace.full}`);
          } else {
            console.log(namespace.full);
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
  .action(() => utilCmd.showHelp());
