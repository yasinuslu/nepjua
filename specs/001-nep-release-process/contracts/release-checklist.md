# Contract: Release Process Checklist

**Feature**: 001-nep-release-process  
**Purpose**: Define the obligations of the release process so that each release satisfies the spec.

## Pre-release

- [ ] Version is decided and tag is chosen (e.g. `v1.0.0`).
- [ ] Release notes are generated (previous release commit → current commit; e.g. via `.cursor/commands/release-notes-generate.md`) and available to paste or inject into the release body.
- [ ] Codebase is in a releasable state (CI green on main or release branch).

## Trigger

- [ ] Maintainer pushes a version tag matching `v*.*.*` (e.g. `git tag v1.0.0 && git push origin v1.0.0`).

## Build & Publish

- [ ] Build runs for **Linux x86_64** and **macOS ARM64** only.
- [ ] If both builds succeed: artifacts are uploaded, checksums are generated, release is created with:
  - Release notes (user-visible changes).
  - Installation and checksum verification instructions in the release body.
  - All artifacts and checksums attached.
- [ ] If either build fails: no release is created; failures must be fixed and a new tag pushed.

## Post-release

- [ ] Documentation (README, docs/) that references version or install/upgrade steps is updated to match the new release.

## Out of scope (per spec)

- Draft or pre-release builds (beta, RC).
- Platforms other than Linux x86_64 and macOS ARM64.
