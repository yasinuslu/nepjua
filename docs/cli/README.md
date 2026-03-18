# Nep CLI (`nep`)

`nep` is a small command-line tool in this repository (sources under `cli/`). Prebuilt binaries are published on [GitHub Releases](https://github.com/yasinuslu/nepjua/releases) for:

- **Linux x86_64** — file `nep-x86_64-unknown-linux-gnu`
- **macOS ARM64 (Apple Silicon)** — file `nep-aarch64-apple-darwin`

**Latest** = most recent stable release on that page (not draft / pre-release).

## Install

1. Open [Releases](https://github.com/yasinuslu/nepjua/releases) and download the asset for your platform.
2. Make it executable:
   ```bash
   chmod +x nep-x86_64-unknown-linux-gnu    # Linux x86_64
   # or
   chmod +x nep-aarch64-apple-darwin        # macOS ARM64
   ```
3. Put it on your `PATH`, for example:
   ```bash
   sudo install -m755 nep-x86_64-unknown-linux-gnu /usr/local/bin/nep
   # or
   sudo install -m755 nep-aarch64-apple-darwin /usr/local/bin/nep
   ```
   Or move the file to any directory on your `PATH` and rename to `nep`.

4. Confirm:
   ```bash
   nep --version
   nep --help
   ```

## Verify download (checksums)

Each release includes `checksums.txt`.

```bash
# After downloading both binaries and checksums.txt into the same directory:
sha256sum -c checksums.txt
```

You should see `OK` for each file present. Only verify the file(s) you downloaded.

## Upgrade

Download the new release’s binary for your platform, replace the old `nep` binary (same path you installed to), then run `nep --version` to confirm.

## Subcommands

Run `nep <command> --help` for full options.

| Command | Description |
|---------|-------------|
| `sops` | SOPS-related helpers |
| `certs` | Certificate utilities |
| `util` | General utilities |
| `secret` | Secret management helpers |
| `completions` | Shell completion setup |

## Build from source (contributors)

From the repo root, with Nix:

```bash
nix develop --command deno task test   # optional
nix develop --command deno compile -A --target x86_64-unknown-linux-gnu --output nep ./cli/main.ts
```

See [Releasing the nep CLI](../development/releasing-nep.md) for maintainers cutting releases.
