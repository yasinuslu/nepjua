import { Command } from "@cliffy/command";
import { externalSecretGet } from "../lib/external-secret.ts";
import { gitFindRoot } from "../lib/git.ts";
import {
  gitopsBuildSopsKeysBundle,
  gitopsKubectlApplyNamespace,
  gitopsKubectlCreateDockerRegistrySecret,
  gitopsKubectlCreateGenericSecretFromFile,
  gitopsWithTempKeysFile,
} from "../lib/gitops.ts";

function fail(error: unknown): never {
  console.error(
    `❌ Error: ${error instanceof Error ? error.message : String(error)}`
  );
  Deno.exit(1);
}

export const gitopsCommand = new Command()
  .name("gitops")
  .description("GitOps cluster bootstrap helpers (SOPS/KSOPS, ArgoCD)")
  .command(
    "sops-secret",
    new Command()
      .description(
        "Assemble per-repo age keys from 1Password into the in-cluster sops-age Secret"
      )
      .option("-n, --namespace <ns:string>", "Target namespace", {
        default: "argocd",
      })
      .action(async (options: { namespace: string }) => {
        try {
          const repoRoot = await gitFindRoot();
          const { bundle, included, skipped } = await gitopsBuildSopsKeysBundle({
            repoRoot,
          });

          if (included.length === 0) {
            throw new Error(
              "No age keys found in 1Password for this repo or any registered Project. " +
                "Run 'nep sops bootstrap' first."
            );
          }

          console.log(`🔑 Included keys: ${included.join(", ")}`);
          if (skipped.length > 0) {
            console.warn(`⚠️  Skipped (no key in 1Password): ${skipped.join(", ")}`);
          }

          await gitopsKubectlApplyNamespace(options.namespace);
          await gitopsWithTempKeysFile(bundle, (filePath) =>
            gitopsKubectlCreateGenericSecretFromFile({
              name: "sops-age",
              namespace: options.namespace,
              fileKey: "keys.txt",
              filePath,
            })
          );
          console.log(
            `✅ sops-age Secret applied in namespace '${options.namespace}' (${included.length} key(s))`
          );
        } catch (error) {
          fail(error);
        }
      })
  )
  .reset()
  .command(
    "ghcr-secret",
    new Command()
      .description(
        "Create the ghcr-pull docker-registry Secret (creds from 1Password global vault, or flags)"
      )
      .option("-n, --namespace <ns:string>", "Target namespace", {
        default: "argocd",
      })
      .option("--user <user:string>", "GHCR username (overrides 1Password)")
      .option("--token <token:string>", "GHCR token (overrides 1Password)")
      .action(
        async (options: { namespace: string; user?: string; token?: string }) => {
          try {
            const username =
              options.user ?? (await externalSecretGet("ghcr/username", true));
            const password =
              options.token ?? (await externalSecretGet("ghcr/token", true));

            await gitopsKubectlApplyNamespace(options.namespace);
            await gitopsKubectlCreateDockerRegistrySecret({
              name: "ghcr-pull",
              namespace: options.namespace,
              server: "ghcr.io",
              username,
              password,
            });
            console.log(
              `✅ ghcr-pull Secret applied in namespace '${options.namespace}'`
            );
          } catch (error) {
            fail(error);
          }
        }
      )
  )
  .reset()
  .action(() => gitopsCommand.showHelp());
