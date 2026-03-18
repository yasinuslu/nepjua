---
description: Generate release notes for the nep CLI by diffing from the previous release commit and producing human-readable notes.
---

## Goal

Generate release notes for the current (upcoming) release of the `nep` CLI. The AI must:

1. **Find the previous release commit**
   - List version tags (e.g. `v*.*.*` or `v*`) in reverse chronological order, or resolve the second-most-recent tag so that "previous release" is unambiguous.
   - If no previous tag exists, treat the root commit or first commit as the base (and say so in the notes).

2. **Get the diff**
   - Compute the diff between the **current commit** (HEAD) and the **previous release commit** (e.g. `git diff PREVIOUS_RELEASE..HEAD` or `git log PREVIOUS_RELEASE..HEAD`).
   - Include file changes and commit messages so the AI has full context.

3. **Generate release notes**
   - From the diff and commit history, produce **human-readable release notes** suitable for a GitHub release (or similar):
     - Short summary of the release.
     - Bullet list of user-visible changes (features, fixes, breaking changes).
     - No raw commit messages unless they are already clear; prefer a concise, curated summary.
   - Output the notes in markdown so they can be pasted into a release body or CHANGELOG.

## Optional user input

If the user provides a version number (e.g. `1.2.0`), include it in the release notes title. Otherwise use a placeholder like "Unreleased" or "Next release".

## Output

- Print the generated release notes (markdown) so the user can copy them into the release or a file.
- If run in a context where the repo or tags are unavailable, explain what went wrong and what to run manually (e.g. `git tag -l 'v*'`, `git diff ...`).
