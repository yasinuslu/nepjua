import { Command } from "@cliffy/command";
import { exists } from "@std/fs/exists";
import { join } from "@std/path";
import { ensureDirectoryContent } from "../lib/fs.ts";
import { nepjuaResolveRootPath } from "../lib/nepjua.ts";

const DEFAULT_HOSTS = ["cache.nixos.org", "registry.npmjs.org"];

const POSSIBLE_SYSTEM_CERT_FILES = [
  "/etc/ssl/certs/ca-certificates.crt",
  "/etc/ssl/certs/ca-certificates.crt.bak",
];

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
  for (const path of POSSIBLE_SYSTEM_CERT_FILES) {
    try {
      if (await exists(path)) {
        console.log(`🔧 Using system certificate file: ${path}`);
        return path;
      }
    } catch (error) {
      if (error instanceof Deno.errors.NotFound) {
        continue;
      }
      throw error;
    }
  }

  throw new Error(
    `No valid certificate file found. Please ensure one of the following exists: ${POSSIBLE_SYSTEM_CERT_FILES.join(
      ", "
    )}`
  );
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

async function checkAndUpdateCerts(hosts: string[] = DEFAULT_HOSTS) {
  try {
    const nepjuaRoot = await nepjuaResolveRootPath();
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
    const systemCertContent = await readCertFile(certFile);

    // Check which certificates are missing
    const extraCerts: string[] = [];

    for (const cert of allCertificates) {
      if (!systemCertContent.includes(cert)) {
        extraCerts.push(cert);
      }
    }

    const fullBundleContent = `
Original Certificate Bundle
============================
${systemCertContent}
============================
Additional Certificates
============================
${extraCerts.join("\n\n")}
============================
    `;

    const extraCertFiles = Object.fromEntries(
      Array.from(allCertificates).map((cert, index) => [
        `extra/${index}.crt`,
        { content: cert },
      ])
    );

    await ensureDirectoryContent(join(nepjuaRoot, ".generated/cert"), {
      ...extraCertFiles,
      "ca-bundle.pem": { content: fullBundleContent },
    });
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
      .action(async (options: { hosts?: string[] }) => {
        const userHosts = options.hosts || [];

        const allHosts = [...new Set([...DEFAULT_HOSTS, ...userHosts])];

        console.log(
          `🌐 Checking certificates for hosts: ${allHosts.join(", ")}`
        );
        await checkAndUpdateCerts(allHosts);
      })
  )
  .reset()
  .action(() => certsCmd.showHelp());
