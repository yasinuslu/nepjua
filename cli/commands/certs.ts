import { Command } from "@cliffy/command";

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

async function writeCertFile(certFile: string, content: string): Promise<void> {
  try {
    await Deno.writeTextFile(certFile, content);
  } catch (error) {
    if (error instanceof Deno.errors.PermissionDenied) {
      console.log(`🔐 Permission denied. Attempting to write with sudo...`);

      // Write to temporary file first
      const tempFile = "/tmp/ca-certificates-updated.crt";
      await Deno.writeTextFile(tempFile, content);

      // Move with sudo
      const result = await runCommand(["sudo", "mv", tempFile, certFile]);

      if (result.code !== 0) {
        throw new Error(
          `Failed to write certificate file with sudo: ${result.stderr}`
        );
      }

      console.log(`✅ Certificate file updated with sudo`);
    } else {
      throw error;
    }
  }
}

async function checkAndUpdateCerts(host: string = "cache.nixos.org") {
  try {
    // Extract certificates from the host
    const certificates = await extractCertificates(host);

    if (certificates.length === 0) {
      console.log("❌ No certificates found");
      return;
    }

    // Get certificate file path
    const certFile = await getCertFile();
    console.log(`📂 Using certificate file: ${certFile}`);

    // Read current certificate file
    const currentContent = await readCertFile(certFile);

    // Check which certificates are missing
    const missingCerts: string[] = [];
    for (const cert of certificates) {
      if (!currentContent.includes(cert.trim())) {
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
      `🔧 Found ${missingCerts.length} missing certificate(s). Adding them...`
    );

    // Add missing certificates
    const updatedContent =
      currentContent + "\n" + missingCerts.join("\n\n") + "\n";

    await writeCertFile(certFile, updatedContent);

    console.log(
      `✅ Successfully added ${missingCerts.length} certificate(s) to ${certFile}`
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
    "check",
    new Command()
      .description("Check and update SSL certificates for Nix cache")
      .option("-h, --host <host>", "Host to check certificates for", {
        default: "cache.nixos.org",
      })
      .action(async (options) => {
        await checkAndUpdateCerts(options.host);
      })
  )
  .reset()
  .action(() => certsCmd.showHelp());
