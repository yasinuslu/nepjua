# Data Model: Nep CLI Release Process

**Feature**: 001-nep-release-process  
**Phase**: 1 (Design)

## Entities (from spec)

### Release

A published version of the nep CLI.

| Attribute        | Description |
|------------------|-------------|
| version          | Unique version identifier (e.g. semantic version: v1.2.3) |
| release_notes    | Human-readable summary of user-visible changes (from git diff → AI generation) |
| artifacts        | One binary per supported platform (Linux x86_64, macOS ARM64) |
| checksums        | One checksum file (e.g. SHA256) covering all artifacts; documented verification steps |
| published_at     | When the release was created (e.g. GitHub Release creation time) |

**Relationships**: Each Release has exactly two artifacts (one per platform). Each Release has one checksum file. Release notes are generated from the diff between the previous release commit and the current (tagged) commit.

**Lifecycle**: Triggered by pushing a version tag (e.g. `v1.0.0`). Build runs for both platforms; if both succeed, release is created with artifacts, checksums, and release notes. If either build fails, no release is published.

**Validation**: Version must match tag pattern (e.g. `v*.*.*`). All artifacts and checksums must be present for the release to be valid.

---

### Documentation

User-facing content that must stay consistent with the current (or latest) release.

| Attribute        | Description |
|------------------|-------------|
| scope            | README, docs/ (and any dedicated CLI page), release body template |
| install_instructions | Instructions for installing the latest stable release on Linux x86_64 and macOS ARM64 |
| upgrade_instructions | Instructions for upgrading from a previous version |
| verification     | How to verify download integrity (checksums) |
| subcommands      | List and short description of CLI subcommands (sops, certs, util, secret, completions) so users can accomplish tasks from docs alone |

**Relationships**: Documentation references the current release version and supported platforms. When a new release is published, docs that reference version or install/upgrade steps are updated (FR-007).

**Validation**: Version references and install/upgrade steps in docs must match the latest release. Documented subcommands and behavior must match the released binary.
