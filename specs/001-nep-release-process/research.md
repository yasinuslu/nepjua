# Research: Nep CLI Release Process

**Feature**: 001-nep-release-process  
**Phase**: 0 (Outline & Research)

## Decisions

### 1. Supported build targets

**Decision**: Build and publish only **Linux x86_64** and **macOS ARM64 (aarch64)**.

**Rationale**: Spec clarification: "Keep it simple." Reduces matrix from four to two jobs; covers common developer machines (Linux servers, Apple Silicon Macs).

**Alternatives considered**: Keeping all four targets (Linux x64/arm64, macOS x64/arm64); adding Windows. Rejected to match spec and reduce maintenance.

---

### 2. Release notes generation

**Decision**: Use the AI command (`.cursor/commands/release-notes-generate.md`): find previous release commit, diff to current, generate human-readable notes. Integrate as a **documented manual step** before creating the release (run command, paste output into release body) or, if feasible, as an automated step that writes release body from script/AI.

**Rationale**: Spec requires release notes from git diff; the AI command already encodes the workflow. Automating the AI step in CI is possible but adds complexity; documenting the manual flow satisfies FR-002 and keeps the first iteration simple.

**Alternatives considered**: Purely manual prose; auto-generating from commit messages only (no AI). Chosen approach balances automation (diff + AI) with simplicity (no required CI integration for AI).

---

### 3. Partial build failure (one platform fails)

**Decision**: If one of the two platform builds fails, the release job should not publish. Require both Linux x86_64 and macOS ARM64 artifacts for a successful release. Document in the release process that a failed build blocks the release and must be fixed before re-tagging.

**Rationale**: Spec edge case: "Users should still be able to get artifacts for platforms that succeeded." With only two platforms, partial publish adds complexity (asymmetric support, confused users). Prefer "all or nothing" for this scope; if both pass, publish; if one fails, fail the release and fix.

**Alternatives considered**: Publish whatever built (partial release). Rejected for simplicity and clear support set.

---

### 4. Documentation scope for "up-to-date"

**Decision**: (1) README: add/update section for nep CLI (what it is, install, upgrade, link to docs). (2) `docs/`: add or update a dedicated page (e.g. `docs/cli/README.md` or section in getting-started) covering: supported platforms, install commands for both platforms, upgrade, checksum verification, and list of subcommands with one-line descriptions and link to usage. (3) Release body template: keep installation and checksum instructions in the GitHub release body so each release is self-contained.

**Rationale**: FR-004, FR-005, FR-006, FR-007 require install, upgrade, subcommand docs, and accuracy with the release. Centralizing CLI docs in one place plus README ensures discoverability and a single source to update per release.

**Alternatives considered**: Scattering CLI docs across multiple guides only; no README mention. Rejected to satisfy "clear instructions" and single-place update.

---

### 5. Version and release trigger

**Decision**: Keep tag-based release: push tag `v*.*.*` (e.g. `v1.0.0`) triggers the workflow. Version in the CLI binary can stay hardcoded or be set at build time from the tag; release notes are generated from previous tag to current tag.

**Rationale**: Matches current release.yml; semantic versioning is assumed. No change to trigger mechanism.

**Alternatives considered**: Release from branch or manual workflow_dispatch. Rejected; tag-based is standard and already in place.
