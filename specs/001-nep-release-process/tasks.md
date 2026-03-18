---
description: "Task list for Nep CLI release process and documentation"
---

# Tasks: Nep CLI Release Process and Up-to-Date Documentation

**Input**: Design documents from `/specs/001-nep-release-process/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested in spec; no test tasks.

**Organization**: Tasks grouped by user story (US1 = release process, US2 = install/upgrade docs, US3 = doc alignment and subcommands).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label for story phases only

## Path Conventions

- Repo root: `.github/workflows/`, `cli/`, `docs/`, `README.md`, `.cursor/commands/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Align on scope before changing automation or docs

- [x] T001 Audit `.github/workflows/release.yml` and `cli/main.ts` against `specs/001-nep-release-process/research.md` and `specs/001-nep-release-process/contracts/release-checklist.md`; record gap list in notes or issue

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Release workflow must match spec (two platforms, all-or-nothing publish) before any story is complete

**⚠️ CRITICAL**: User story work assumes this phase completes first

- [x] T002 Restrict build matrix in `.github/workflows/release.yml` to **x86_64-unknown-linux-gnu** and **aarch64-apple-darwin** only (remove aarch64-linux and x86_64-darwin jobs per FR-008)
- [x] T003 Add a gate in `.github/workflows/release.yml` release job: verify both expected binaries exist (`nep-x86_64-unknown-linux-gnu`, `nep-aarch64-apple-darwin`) before creating the GitHub Release; fail the job if either is missing (per research: no partial release)

**Checkpoint**: Tag push builds only two targets; release is not published unless both succeed

---

## Phase 3: User Story 1 - Maintainer Cuts a New Release (Priority: P1) 🎯 MVP

**Goal**: Repeatable release with correct artifacts, checksums, and release notes workflow

**Independent Test**: Push a test tag on a fork or dry-run review: workflow produces two artifacts, checksums file, release body with install instructions; maintainer can follow `specs/001-nep-release-process/quickstart.md`

### Implementation for User Story 1

- [x] T004 [US1] Update `.github/workflows/release.yml` release body template: installation section must name **Linux x86_64** and **macOS ARM64** artifacts explicitly (`nep-x86_64-unknown-linux-gnu`, `nep-aarch64-apple-darwin`); remove generic four-platform wording
- [x] T005 [US1] Add `docs/development/releasing-nep.md` documenting: run release-notes via `.cursor/commands/release-notes-generate.md`, update `cli/main.ts` version, tag `v*.*.*`, push, verify workflow; link to `specs/001-nep-release-process/contracts/release-checklist.md`
- [x] T006 [US1] Align `cli/main.ts` `.version()` with the tagging process (document in `docs/development/releasing-nep.md` that version must match tag, or implement compile-time version from tag if preferred)

**Checkpoint**: Maintainer can cut a release following docs; GitHub Release matches two-platform spec

---

## Phase 4: User Story 2 - User Installs or Upgrades Nep (Priority: P2)

**Goal**: Users install or upgrade from official documentation only

**Independent Test**: Follow `docs/cli/README.md` install and upgrade sections on Linux x64 and macOS ARM64 without repo insider knowledge

### Implementation for User Story 2

- [x] T007 [P] [US2] Create `docs/cli/README.md` with installation steps (download from GitHub Releases, `chmod +x`, PATH), upgrade steps (replace binary), and checksum verification using `checksums.txt` for both supported platforms
- [x] T008 [US2] Add a **Nep CLI** subsection to `README.md` with one-paragraph description, supported platforms, and link to `docs/cli/README.md`

**Checkpoint**: New user can install in under 5 minutes per spec SC-002

---

## Phase 5: User Story 3 - Documentation Stays Aligned (Priority: P3)

**Goal**: Subcommands documented; docs index updated; version semantics clear

**Independent Test**: Audit `docs/cli/README.md` and `README.md` against `nep --help` / released binary; run post-release doc update checklist from `docs/development/releasing-nep.md`

### Implementation for User Story 3

- [x] T009 [P] [US3] Extend `docs/cli/README.md` with subcommand list per `contracts/cli-docs-surface.md`: `sops`, `certs`, `util`, `secret`, `completions` — one-line description each plus `nep <cmd> --help` guidance
- [x] T010 [US3] Add `docs/cli/README.md` to `docs/README.md` Documentation Structure and Quick Links
- [x] T011 [US3] In `docs/development/releasing-nep.md`, add explicit post-release step: update any version-pinned or install URLs in `README.md` and `docs/cli/README.md` to match the new release (FR-007); define **latest** as most recent stable GitHub Release

**Checkpoint**: Docs match released CLI; maintainers know to refresh docs on each release

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Consistency and command accuracy

- [x] T012 [P] Update `.cursor/commands/release-notes-generate.md` examples to reference two-platform artifact names if they still mention four targets
- [x] T013 Validate `specs/001-nep-release-process/quickstart.md` against final workflow and doc paths; fix broken links or outdated commands

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** → **Phase 2** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5 (US3)** → **Phase 6**
- US2 and US3 can start after Phase 2 in parallel with US1 **only** if release.yml is already two-platform and gated (T002–T003 done); otherwise complete US1 workflow edits first to avoid doc churn

### User Story Dependencies

- **US1**: Depends on Phase 2; delivers working release pipeline
- **US2**: Depends on US1 for accurate release URLs/names in docs (can draft docs in parallel after T002–T003)
- **US3**: Depends on US2 base page (`docs/cli/README.md`); extends same file

### Parallel Opportunities

- T007 and T009 both touch `docs/cli/README.md` — **do not parallelize** T007 with T009; run T007 before T009
- T012 and T013 are parallelizable after Phase 5
- T002 and T003 are sequential (same file `release.yml`)

### Parallel Example: After Phase 5

```bash
# T012 and T013 in parallel:
Task: ".cursor/commands/release-notes-generate.md"
Task: "specs/001-nep-release-process/quickstart.md validation"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1–2 (release.yml two targets + gate)
2. Complete Phase 3 (US1): release body, releasing-nep.md, version alignment
3. **STOP and VALIDATE**: Tag a release (or dry-run) and confirm two artifacts + checksums

### Incremental Delivery

1. US1 → working releases  
2. US2 → users can install from docs  
3. US3 → full doc surface + release hygiene  
4. Polish → command and quickstart accuracy  

---

## Notes

- Every task includes at least one concrete file path
- Commit after each phase or logical group
- Re-run `/speckit.analyze` after tasks.md is stable
