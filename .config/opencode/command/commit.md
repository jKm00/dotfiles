---
description: Commit all uncommitted changes, grouped into logical commits
agent: git-cheap
subtask: false
---

Commit the current uncommitted work in this repository, split into logical, self-contained commits.

Follow these steps:

1. Run `git status --short` and `git diff` (and `git diff --staged`) to see every uncommitted change, tracked and untracked.
2. Review the recent history with `git log --oneline -10` to match the repo's existing commit message style (e.g. Conventional Commits).
3. Group the changes into logical commits. Each commit must be one coherent, self-contained change — do NOT dump everything into a single commit. Typical groupings:
   - A feature and its tests together.
   - A bug fix separate from an unrelated refactor.
   - Formatting/whitespace-only changes separate from behavioral changes.
   - Config/tooling changes separate from application code.
4. For each group, stage only that group's files with an explicit `git add <paths>` (never blanket `git add -A` unless the entire working tree is genuinely one logical change), then commit with a concise message that follows the repo's convention.
5. Before staging, inspect the changes for secrets, credentials, or large unintended files. If you find any, stop and report instead of committing them.
6. Do NOT push, amend existing commits, force-push, or create empty commits.
7. After committing, run `git status` and show `git log --oneline` for the new commits so the result is verifiable.

If the working tree is clean, report that there is nothing to commit and stop.

Additional context or constraints from the user: $ARGUMENTS
