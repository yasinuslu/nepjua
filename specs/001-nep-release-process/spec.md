# Feature Specification: Nep CLI Release Process and Up-to-Date Documentation

**Feature Branch**: `001-nep-release-process`  
**Created**: 2025-03-15  
**Status**: Draft  
**Input**: User description: "Need a proper release process for the `nep` command line tool. And all documentation must be up-to-date"

## Clarifications

### Session 2025-03-15

- Q: How should "supported platforms" be defined for the release process and docs? → A: Keep it simple: Linux x64 and macOS arm64 only.
- Q: Should the release process support pre-release or draft releases (betas, RCs)? → A: Only stable releases; no formal support for betas/RCs or draft releases.
- Q: Should release notes be human-written or auto-generated? → A: AI-generated from git: find previous release commit, get diff (current vs previous release), generate release notes from that diff.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintainer Cuts a New Release (Priority: P1)

As a maintainer, I want to follow a clear, repeatable process to publish a new version of the `nep` CLI so that users can get the latest changes reliably and I avoid mistakes.

**Why this priority**: Without a defined release process, releases are ad hoc and error-prone; this is the core capability.

**Independent Test**: Can be fully tested by performing one full release from version bump to published artifacts and verifying artifacts and release notes are correct.

**Acceptance Scenarios**:

1. **Given** the codebase is in a releasable state, **When** the maintainer initiates a release, **Then** a new version is published with artifacts for supported platforms and release notes describing changes.
2. **Given** a release has been published, **When** a user visits the project, **Then** they can find clear instructions on how to download and install the released version for their platform.
3. **Given** a release is in progress, **When** artifacts are built, **Then** users can verify integrity of downloads (e.g. via checksums).

---

### User Story 2 - User Installs or Upgrades Nep (Priority: P2)

As a user, I want to install or upgrade the `nep` CLI using documented, up-to-date instructions so that I can run the tool without guessing or outdated steps.

**Why this priority**: Documentation is required for adoption and safe upgrades; it depends on the release being published (P1).

**Independent Test**: Can be tested by a new user following only the documented instructions to install the latest release and run a basic command successfully.

**Acceptance Scenarios**:

1. **Given** I am on a supported platform, **When** I follow the official installation instructions, **Then** I can install the latest release and run `nep` successfully.
2. **Given** I have an older version installed, **When** I follow the documented upgrade instructions, **Then** I can upgrade to the latest release without confusion.
3. **Given** I need to verify a download, **When** I follow the documentation, **Then** I can verify the binary using the provided checksums or equivalent.

---

### User Story 3 - Documentation Stays Aligned with Releases (Priority: P3)

As a maintainer or contributor, I want all user-facing documentation to reflect the current (or upcoming) release so that users are never led astray by outdated commands, versions, or behavior.

**Why this priority**: Reduces support burden and builds trust; complements P1 and P2.

**Independent Test**: Can be tested by auditing docs for version numbers, install commands, and feature descriptions and confirming they match the latest release or mainline behavior.

**Acceptance Scenarios**:

1. **Given** a release has been published, **When** I read the main project documentation, **Then** referenced version numbers and install/upgrade instructions match the latest release.
2. **Given** the CLI has subcommands or options, **When** I read the docs, **Then** documented commands and behavior match what the released binary supports.
3. **Given** the release process or supported platforms change, **When** the change is made, **Then** the documentation is updated in the same release or immediately after.

---

### Edge Cases

- What happens when a release is triggered but a build for one platform fails? Users should still be able to get artifacts for platforms that succeeded, and the process should make it clear which platforms are available.
- The release process targets **stable releases only**; there is no formal support for draft, beta, or release-candidate builds. Users can assume every published release is production-ready.
- What happens when documentation references a version that does not exist yet (e.g. "next" or "latest")? References should be unambiguous (e.g. "latest" clearly means "most recent stable release") so users are not confused.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST have a defined, repeatable release process that produces published artifacts for all supported platforms from a single release trigger.
- **FR-002**: Each release MUST be identified by a unique version (e.g. semantic version) and MUST include release notes describing user-visible changes. Release notes MUST be generated by: (1) resolving the previous release commit (e.g. previous version tag), (2) computing the diff from that commit to the current release commit, (3) producing human-readable release notes from that diff (e.g. via an AI command or script). Only stable releases are published; draft/pre-release (beta, RC) builds are out of scope.
- **FR-003**: Release artifacts MUST be verifiable by users (e.g. checksums or equivalent) and the verification method MUST be documented.
- **FR-004**: Official documentation MUST include installation instructions for the latest stable release on all supported platforms.
- **FR-005**: Official documentation MUST include upgrade instructions for users who already have a previous version installed.
- **FR-006**: Documentation MUST describe the available subcommands and how to use them so that a new user can accomplish common tasks from the docs alone.
- **FR-007**: When a new release is published, documentation that references version numbers or install/upgrade steps MUST be updated so it stays accurate for that release.
- **FR-008**: The project MUST document supported platforms. Supported platforms are **Linux x86_64** and **macOS ARM64 (aarch64)** only; the release process and documentation target these two platforms.

### Key Entities

- **Release**: A published version of the CLI with a unique version identifier, release notes, and artifacts per platform.
- **Documentation**: User-facing content (e.g. README, guides, install/upgrade instructions) that must stay consistent with the current or latest release.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A maintainer can complete a full release (from decision to release to published artifacts and notes) in under 15 minutes when following the documented process.
- **SC-002**: A new user can install the latest stable release on a supported platform using only the official documentation in under 5 minutes.
- **SC-003**: After a release, all documented version references and install/upgrade instructions match that release with no known outdated or broken steps.
- **SC-004**: Users can verify download integrity for every artifact using documented steps (checksums or equivalent) for 100% of published artifacts.

## Assumptions

- The CLI is distributed as standalone binaries per platform; installation via a package manager (e.g. system package manager or third-party) is optional and may be documented as an alternative if available.
- Supported platforms are fixed for this feature: Linux x86_64 and macOS ARM64 (aarch64). The release process and docs target only these two; adding or changing platforms is out of scope.
- Release notes are generated automatically from git: the process uses the previous release commit, the diff from that commit to the current (release) commit, and an AI step to produce human-readable release notes from that diff.
- Documentation lives in the same repository as the code so that doc updates can be part of the same release or branch.
- Only stable releases are in scope; the process does not support publishing draft, beta, or release-candidate builds.
