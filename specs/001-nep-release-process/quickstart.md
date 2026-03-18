# Quickstart: Nep CLI Release and Documentation

**Feature**: 001-nep-release-process

## Maintainer: Cutting a release

See **[docs/development/releasing-nep.md](../../docs/development/releasing-nep.md)** for the canonical runbook (version bump, tag, post-release doc updates).

1. **Ensure CI is green** on the branch you intend to tag (e.g. `main`).
2. **Generate release notes** — Cursor command **release-notes-generate** (`.cursor/commands/release-notes-generate.md`).
3. **Match `cli/main.ts` `.version()` to the tag** (e.g. `v0.1.0` → `"0.1.0"`).
4. **Tag and push** — `git tag v0.1.0 && git push origin v0.1.0`
5. **Watch the workflow** — [`.github/workflows/release.yml`](../../.github/workflows/release.yml); both platforms must succeed.
6. **Paste release notes** into the GitHub Release **Changes** section after publish.
7. **Update docs** per [releasing-nep.md](../../docs/development/releasing-nep.md) (README / `docs/cli/` if needed).

Full checklist: [contracts/release-checklist.md](./contracts/release-checklist.md).

## User: Installing nep

1. Open the [GitHub Releases](https://github.com/yasinuslu/nepjua/releases) page (or the repo’s release URL).
2. Download the binary for your platform:
   - **Linux x86_64**: `nep-x86_64-unknown-linux-gnu` (or the artifact name for that target).
   - **macOS ARM64**: `nep-aarch64-apple-darwin` (or the artifact name for that target).
3. Make it executable: `chmod +x nep-<target>`.
4. (Optional) Verify the download using `checksums.txt` from the same release (see release body or docs for the exact command).
5. Move the binary to a directory on your PATH or run it by path.

Upgrade: repeat the same steps with the new release and replace the old binary.

Detailed install, upgrade, and verification steps live in the repo docs and in each release body.
