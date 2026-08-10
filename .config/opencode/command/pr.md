---
description: Create a GitHub PR for the current branch with a description generated from the diff
agent: git-cheap
subtask: false
---

Create a GitHub pull request for the currently checked-out branch, with a title and body derived from the actual changes.

Optional context or constraints from the user: $ARGUMENTS

## Setup

1. Confirm this is a git repo and `gh` is available (`gh auth status`). If not authenticated, stop and tell the user to run `gh auth login`.
2. Determine the base branch: prefer `main`, else `master`.
3. If the current branch IS the base branch, stop and report — there is nothing to PR from the base branch.
4. Compute `git merge-base HEAD <base>` and confirm there is a diff (`git diff --stat <merge-base>..HEAD`). If the branch matches base, report "No changes vs <base>" and stop.
5. Check for an existing PR: `gh pr view --json url,state 2>/dev/null`. If one already exists and is open, ask whether to update its body instead of creating a new PR.

## Gather context

6. Read the full picture before writing anything:
   - `git log <base>..HEAD --oneline` — every commit on the branch.
   - `git diff <merge-base>..HEAD` — the actual changes (skim large diffs; focus on behavioral changes, not lockfiles/generated files).
   - Check for a PR template: look for `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, or files under `.github/PULL_REQUEST_TEMPLATE/`. If one exists, follow its structure exactly.

## Push

7. If the branch has no upstream, push with `git push -u origin HEAD`. Otherwise ensure local commits are pushed (`git push`). Never force-push.

## Write and create

8. Compose the PR:
   - **Title**: concise, imperative, matching the repo's commit convention (e.g. Conventional Commits if the history uses it). Derive from the collective intent of the commits, not just the last one.
   - **Body**: if a template exists, fill it. Otherwise use this structure:
     ```
     ## What
     <1-3 sentences: what this PR does>

     ## Why
     <the motivation / problem being solved>

     ## Changes
     - <bullet per meaningful change, grouped logically>

     ## Testing
     <how it was verified, or "Not yet tested" if unknown — never fabricate>
     ```
   - Be accurate and specific. Do NOT invent testing that wasn't done, tickets that don't exist, or behavior not present in the diff. If you're unsure about intent, state the observable change rather than guessing motivation.
9. Create the PR against the base branch using `gh pr create --base <base> --title "<title>" --body "<body>"`. Pass the body via a temp file or heredoc to preserve formatting.
10. Output the resulting PR URL.

## Rules

- Never fabricate content — every claim in the body must be traceable to a commit or diff hunk.
- Do NOT merge, request reviewers, add labels, or change PR settings unless the user explicitly asked in $ARGUMENTS.
- Keep the body tight — reviewers skim. No filler, no restating the diff line by line.
- If the diff contains anything that looks like a secret or credential, stop and warn the user before pushing or creating the PR.
