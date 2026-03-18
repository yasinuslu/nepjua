# Implementation Plan: Nep CLI Release Process and Up-to-Date Documentation

**Branch**: `001-nep-release-process` | **Date**: 2025-03-15 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-nep-release-process/spec.md`

## Summary

Implement a repeatable release process for the `nep` CLI that: (1) builds and publishes binaries for Linux x86_64 and macOS ARM64 only; (2) generates release notes from git diff (previous release commit → current) via the existing AI command; (3) publishes checksums and install/upgrade docs; (4) keeps all user-facing documentation aligned with the current release. Technical approach: adjust the existing GitHub Actions release workflow to the two target platforms, wire release notes generation into the release flow (or documented manual step), and add/update docs (README, docs/) for install, upgrade, subcommands, and checksum verification.

## Technical Context

**Language/Version**: Deno (runtime for CLI); Nix for dev/build environment  
**Primary Dependencies**: @cliffy/command (CLI), Nix flake, GitHub Actions  
**Storage**: N/A (CLI; release artifacts on GitHub Releases)  
**Testing**: Deno test, Nix develop; CI runs tests, fmt, lint  
**Target Platform**: Linux x86_64, macOS ARM64 (aarch64) only (per spec)  
**Project Type**: CLI (nep) within a Nix config repo  
**Performance Goals**: Release completion in under 15 minutes; install from docs under 5 minutes (per spec)  
**Constraints**: Stable releases only; no draft/beta/RC; two platforms only  
**Scale/Scope**: Single maintainer; one CLI binary; docs in repo (README, docs/)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution (`.specify/memory/constitution.md`) is a template with no project-specific principles defined. No gates are enforced; proceeding with the plan.

## Project Structure

### Documentation (this feature)

```text
specs/001-nep-release-process/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1 (release checklist; CLI doc surface)
└── tasks.md             # From /speckit.tasks
```

### Source Code (repository root)

```text
cli/
├── main.ts              # Nep entrypoint
├── commands/            # Subcommands (sops, certs, util, secret)
├── lib/
└── zx-configuration.ts

.github/
└── workflows/
    ├── ci.yml           # Test, fmt, lint on main/PR
    └── release.yml      # Build on tag push; create GitHub Release

docs/                    # User-facing docs (install, guides, features, etc.)
README.md                # Project + install/upgrade for nep

my-shell/                # Nix dev shell (deno, etc.)
```

**Structure Decision**: Single repo with `cli/` for the nep tool, `.github/workflows/` for CI and release, and `docs/` plus README for documentation. Release workflow changes are confined to `release.yml` and doc files.

## Complexity Tracking

No constitution violations; this section is unused.
