# Quickstart: Nep CLI Release and Documentation

**Feature**: 001-nep-release-process

## Maintainer: Cutting a release

1. **Ensure CI is green** on the branch you intend to tag (e.g. `main`).
2. **Generate release notes**  
   Run the release-notes AI command (e.g. in Cursor: use the command that finds the previous release commit, diffs to current, and generates notes). Copy the markdown output.
3. **Tag and push**  
   Choose a version (e.g. `1.0.0`). Create and push the tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. **Watch the release workflow**  
   GitHub Actions builds for Linux x86_64 and macOS ARM64. When both succeed, a GitHub Release is created with artifacts and checksums.
5. **Paste release notes**  
   If the workflow does not inject the generated notes, edit the release on GitHub and paste the release notes into the release body (you can keep the default install/checksum template and add the generated “Changes” section above it).
6. **Update docs**  
   Update README and any CLI docs so that version references, install, and upgrade instructions match the new release. Commit and push.

See [contracts/release-checklist.md](./contracts/release-checklist.md) for the full checklist.

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
