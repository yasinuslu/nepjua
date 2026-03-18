# T001 — Pre-implementation audit (gap list)

**Compared against**: `research.md`, `contracts/release-checklist.md`

| Gap | Location | Resolution |
|-----|----------|------------|
| Four build targets; spec requires Linux x86_64 + macOS ARM64 only | `.github/workflows/release.yml` | T002 |
| Release could publish with fewer than two artifacts (partial matrix failure) | `release.yml` release job | T003 |
| Generic `nep-<target>` install text; not explicit artifact names | Release body | T004 |
| No maintainer-facing release runbook | Repo docs | T005 |
| `cli/main.ts` version `0.0.1` not tied to tag process | `cli/main.ts` + docs | T006 |
| No user install/upgrade/checksum docs | `docs/` | T007–T008 |
| Subcommands not documented for end users | `docs/cli/` | T009 |
| Docs index missing CLI page | `docs/README.md` | T010 |
| Post-release doc refresh not explicit | Releasing doc | T011 |
