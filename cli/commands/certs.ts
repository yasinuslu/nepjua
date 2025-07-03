import { Command } from "@cliffy/command";
import path from "node:path";
import { gitFindRoot } from "../lib/git.ts";
import type { SecretSchemaType } from "../lib/secret/schema.ts";
import { secretRead, secretWrite } from "../lib/secret/secret.ts";

const DEFAULT_HOSTS = ["cache.nixos.org", "registry.npmjs.org"];

async function getHostConfigurationFolder(host: string): Promise<string> {
  const gitRoot = await gitFindRoot();
  const hostConfigPath = path.join(gitRoot, "hosts", host);
  return hostConfigPath;
}

async function runCommand(
  cmd: string[]
): Promise<{ stdout: string; stderr: string; code: number }> {
  const process = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await process.output();

  return {
    stdout: new TextDecoder().decode(stdout),
    stderr: new TextDecoder().decode(stderr),
    code,
  };
}

async function extractCertificates(host: string): Promise<string[]> {
  console.log(`📡 Connecting to ${host} to extract certificates...`);

  const result = await runCommand([
    "openssl",
    "s_client",
    "-connect",
    `${host}:443`,
    "-showcerts",
  ]);

  if (result.code !== 0) {
    throw new Error(`Failed to connect to ${host}: ${result.stderr}`);
  }

  const certRegex =
    /-----BEGIN CERTIFICATE-----[\s\S]*?-----END CERTIFICATE-----/g;
  const certificates = result.stdout.match(certRegex) || [];

  console.log(`🔍 Found ${certificates.length} certificate(s)`);
  return certificates;
}

async function getCertFile(): Promise<string> {
  const nixSslCertFile = Deno.env.get("NIX_SSL_CERT_FILE");
  if (nixSslCertFile) {
    return nixSslCertFile;
  }

  const defaultPath = "/etc/ssl/certs/ca-certificates.crt";
  console.log(`🔧 Using default certificate file: ${defaultPath}`);
  return defaultPath;
}

async function readCertFile(certFile: string): Promise<string> {
  try {
    return await Deno.readTextFile(certFile);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      throw new Error(`Certificate file not found: ${certFile}`);
    } else if (error instanceof Deno.errors.PermissionDenied) {
      throw new Error(
        `Permission denied reading certificate file: ${certFile}. You may need to run with sudo.`
      );
    }
    throw error;
  }
}

async function ensureDirectoryExists(filePath: string): Promise<void> {
  const dir = filePath.substring(0, filePath.lastIndexOf("/"));
  try {
    await Deno.mkdir(dir, { recursive: true });
  } catch (error) {
    if (!(error instanceof Deno.errors.AlreadyExists)) {
      throw error;
    }
  }
}

async function checkAndUpdateCerts(
  hosts: string[] = DEFAULT_HOSTS,
  destinationHost: keyof SecretSchemaType["hosts"]
) {
  try {
    // Extract certificates from all hosts
    const allCertificates = new Set<string>();

    for (const host of hosts) {
      const certificates = await extractCertificates(host);
      certificates.forEach((cert) => allCertificates.add(cert.trim()));
    }

    if (allCertificates.size === 0) {
      console.log("❌ No certificates found from any host");
      return;
    }

    console.log(
      `🔍 Total unique certificates found across all hosts: ${allCertificates.size}`
    );

    // Get certificate file path for comparison
    const certFile = await getCertFile();
    console.log(`📂 Comparing against certificate file: ${certFile}`);

    // Read current certificate file
    const currentContent = await readCertFile(certFile);

    // Check which certificates are missing
    const missingCerts: string[] = [];

    for (const cert of allCertificates) {
      if (!currentContent.includes(cert)) {
        missingCerts.push(cert);
      }
    }

    if (missingCerts.length === 0) {
      console.log(
        "✅ All certificates are already present in the certificate file"
      );
      return;
    }

    console.log(
      `🔧 Found ${missingCerts.length} missing certificate(s). Writing them to destination file...`
    );

    const mainSecret = await secretRead();
    mainSecret.hosts[destinationHost].certificates = missingCerts;
    await secretWrite(mainSecret);

    console.log(
      `✅ Successfully wrote ${missingCerts.length} missing certificate(s) to ${destinationHost}`
    );
  } catch (error) {
    console.error(
      `❌ Error: ${error instanceof Error ? error.message : String(error)}`
    );
    Deno.exit(1);
  }
}

export const certsCmd = new Command()
  .name("certs")
  .description("Certificate management for Nix SSL")
  .command(
    "update",
    new Command()
      .description(
        `Check and update SSL certificates for Nix cache.

Unlike most macOS applications that integrate with the system keychain,
Nix relies on a static certificate bundle file for SSL verification.
This can cause issues in environments with custom certificate authorities
or intermediate certificates that aren't included in the default bundle.

This command helps maintain certificate compatibility by extracting current
certificates from the target hosts, comparing with the local certificate bundle,
and adding any missing certificates to ensure proper SSL verification.

The certificate bundle may be reset during system updates or package reinstalls,
making this automation useful for maintaining consistent Nix functionality.

Default hosts checked: cache.nixos.org, registry.npmjs.org`
      )
      .option(
        "-h, --hosts <hosts...>",
        "Additional hosts to check certificates for"
      )
      .option(
        "-d, --destination <destination>",
        "Destination host to write certificates to",
        {
          default: "chained",
        }
      )
      .action(async (options: { hosts?: string[]; destination: string }) => {
        const userHosts = options.hosts || [];

        const allHosts = [...new Set([...DEFAULT_HOSTS, ...userHosts])];

        console.log(
          `🌐 Checking certificates for hosts: ${allHosts.join(", ")}`
        );
        await checkAndUpdateCerts(allHosts, options.destination as never);
      })
  )
  .reset()
  .action(() => certsCmd.showHelp());
