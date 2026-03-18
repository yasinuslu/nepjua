# Contract: CLI Documentation Surface

**Feature**: 001-nep-release-process  
**Purpose**: Define what the official documentation must cover so users can install, upgrade, verify, and use the nep CLI from docs alone (FR-004, FR-005, FR-006).

## Supported platforms (must be documented)

- Linux x86_64
- macOS ARM64 (aarch64)

## Required documentation sections

1. **Installation**
   - How to download the binary for the user’s platform (e.g. GitHub Releases URL pattern).
   - How to make the binary executable and place it on PATH (or equivalent).
   - Optional: alternative install methods (e.g. Nix, package manager) if available.

2. **Upgrade**
   - How to replace an existing `nep` binary with a newer release (download new binary, replace old one, or equivalent).

3. **Verification**
   - How to obtain checksums for the release (e.g. `checksums.txt` in the release).
   - How to verify a downloaded binary (e.g. `sha256sum -c` or equivalent) so users can confirm integrity.

4. **Subcommands and usage**
   - List of top-level subcommands: `sops`, `certs`, `util`, `secret`, `completions`.
   - For each: one-line description and, if needed, link or reference to detailed usage so a new user can accomplish common tasks from the docs alone.

## Where this appears

- README: high-level mention of nep, link to install/upgrade and CLI docs.
- Dedicated CLI doc (e.g. `docs/cli/README.md` or a section in getting-started): full install, upgrade, verification, subcommand list.
- GitHub Release body (template): installation and checksum verification so each release is self-contained.

## Consistency rule

When a new release is published, any doc that references version numbers or install/upgrade/verification steps must be updated to match that release (FR-007).
