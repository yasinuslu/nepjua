# Releasing the `nep` CLI

This repo publishes **stable** releases of the `nep` command-line tool for **Linux x86_64** and **macOS ARM64** only. Pushing a tag `v*.*.*` triggers the [Release workflow](../../.github/workflows/release.yml).

Full checklist: [release-checklist contract](../../specs/001-nep-release-process/contracts/release-checklist.md).

## Before you tag

1. **CI green** on the branch you will tag (usually `main`).
2. **Version in code** — In `cli/main.ts`, the string passed to `.version(...)` **must match the tag without the `v` prefix** (e.g. tag `v1.2.3` → `.version("1.2.3")`). Update it in the same commit you release from.
3. **Release notes** — Run the Cursor command **release-notes-generate** (see `.cursor/commands/release-notes-generate.md`): it finds the previous release tag, diffs to `HEAD`, and produces markdown. Copy the output; you will paste it into the GitHub Release after it is created (or edit the release body).

## Tag and push

```bash
git tag v0.1.0   # example; must match .version() without "v"
git push origin v0.1.0
```

GitHub Actions builds both binaries. If **either** build fails, the release job **does not** publish assets (no partial release).

## After the release is live

1. Open the new release on GitHub.
2. Paste your AI-generated notes into the **Changes** section (replace the placeholder text if needed).
3. **Update documentation (FR-007)**:
   - If you added version-specific URLs or examples in [`README.md`](../../README.md) or [`docs/cli/README.md`](../cli/README.md), align them with the new release.
   - **Latest** means the most recent **stable** GitHub Release (not draft, not pre-release).

## Quick reference

| Item | Value |
|------|--------|
| Tag pattern | `vMAJOR.MINOR.PATCH` |
| Linux artifact | `nep-x86_64-unknown-linux-gnu` |
| macOS ARM64 artifact | `nep-aarch64-apple-darwin` |
| Checksums | `checksums.txt` on the release |
