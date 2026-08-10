---
description: Reconcile docs (README and others) with the current state of the repo
agent: git-cheap
subtask: false
---

Update the repository's documentation so it accurately describes the CURRENT
state of the repo. This is a reconciliation task, not a changelog task.

## Core principle

Documentation must describe how things ARE right now — the current setup,
structure, behavior, and configuration. It must NOT describe how things used to
be, what changed, or why the change was made. Git already holds the history;
never duplicate that history in prose.

- NEVER write "previously", "changed from X to Y", "now uses", "no longer",
  "as of this update", "was renamed", "used to", or any before/after framing.
- NEVER add changelog entries, migration notes, or "what's new" sections unless
  such a section already exists in the doc and is part of its intended
  structure.
- A design decision (WHY something is done a certain way) MAY be documented, but
  ONLY as a present-tense statement of the current rationale, and ONLY if it
  fits the document's existing structure. Frame it as "X is done this way
  because Y", never as a history of alternatives that were tried.

If you catch yourself explaining a transition, stop and rewrite it as a plain
present-tense description of the end state.

## What to reconcile against

1. Identify the changes that have made the docs stale. Combine two signals:
   - The work done in the current session (files created, edited, deleted, and
     the behavior/config those changes introduced).
   - Git drift: inspect recent history and the working tree to find where the
     repo's reality has diverged from what the docs claim. Useful commands:
     - `git status --short` and `git diff` for uncommitted work.
     - `git log --oneline -20` to see recent commits.
     - Compare when docs were last touched vs. the code they describe, e.g.
       `git log --oneline -5 -- README.md` and `git log --oneline -10 -- <path>`
       to spot code that changed after the doc did.
2. Focus on the docs most likely affected: `README.md` first, then other
   Markdown/docs files (`docs/**`, `AGENTS.md`, `CONTRIBUTING.md`, and similar).
   Only touch a doc if the repo's current truth actually contradicts or has
   outgrown what it says.

## Steps

1. Determine what changed (session work + git drift, per above).
2. For each candidate doc, read it in full and compare its claims against the
   real current state of the repo (config files, scripts, directory layout,
   commands, aliases, etc.). Verify claims against the actual files — do not
   trust the doc's own description.
3. Edit only the sections that are now inaccurate, incomplete, or missing.
   Rewrite them as clean present-tense descriptions of the current state. Match
   the existing tone, formatting, heading style, and structure of each doc.
4. Remove documentation for things that no longer exist. Add documentation for
   current things that are undocumented and belong in that doc.
5. Do not invent behavior. Every statement you write must be verifiable against
   a file in the repo. If something is ambiguous, describe the observable
   current behavior rather than guessing intent.
6. Keep edits tight and surgical. Do not reflow or restructure whole documents
   when a focused edit suffices.

## Boundaries

- Do NOT stage or commit anything. Leave all edits in the working tree for
  review.
- Do NOT push, create branches, or run any git write operations.
- Only modify documentation files. Do not change code, config, or scripts to
  make them match the docs — the repo is the source of truth, the docs follow.

## Report

After editing, list each doc you changed and, in one line per doc, what it now
correctly describes. If no docs were out of sync, say so and change nothing.

Additional context or constraints from the user: $ARGUMENTS
