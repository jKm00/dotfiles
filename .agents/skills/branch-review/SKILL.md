---
name: branch-review
description: >
  Review all changes on the current feature branch before creating a pull request.
  Use this skill whenever the user wants to review their branch, check their changes
  before a PR, do a pre-PR review, self-review their code, or asks things like
  "review my changes", "look at what I've done on this branch", "check my branch
  before I open a PR", "review my diff", or "what does my branch look like".
  Also trigger when the user says "pre-PR check", "review before merging", or
  "audit my feature branch". This skill also applies when the user wants to review
  a teammate's PR or branch changes. Trigger this skill whenever the user mentions
  reviewing code changes on a branch, checking a diff, or doing any kind of code
  review tied to a branch or pull request -- even if they don't explicitly say
  "branch review".
---

# Branch Review

You are performing a constructive, thorough code review of all changes on the current feature branch. The goal is to help the developer catch issues and improve their code *before* it goes into a pull request -- saving review cycles and improving code quality.

## Philosophy

A great pre-PR review is not a list of complaints. It's a conversation with the code that helps the author see their work with fresh eyes. For every issue you find, explain *why* it matters and suggest a concrete improvement. Group your findings by file so the developer can work through them systematically.

The review should feel like getting feedback from a senior colleague who genuinely wants your code to succeed -- direct and honest, but always constructive.

## Step 1: Determine the base branch

Auto-detect the base branch by checking, in order:

1. The upstream tracking branch (`git rev-parse --abbrev-ref @{upstream}` -- extract the branch name from `origin/<branch>`)
2. If that fails, check which of these branches exist locally: `dev`, `develop`, `development`, `main`, `master`
3. Use the first one found

If none are found, ask the user which branch to compare against.

Once you have the base branch, store it -- you'll reference it in the next steps.

## Step 2: Gather the changes

Run these commands to understand the full scope of changes:

```bash
# The commits on this branch that aren't on the base branch
git log --oneline <base>..HEAD

# The full diff (this is the primary input for review)
git diff <base>..HEAD

# Summary of which files changed and how much
git diff --stat <base>..HEAD
```

Also check for any uncommitted changes with `git status` and `git diff` (unstaged) / `git diff --cached` (staged). If there are uncommitted changes, mention them at the top of the review -- the developer might have forgotten to commit something.

## Step 3: Understand context

Before you start reviewing line-by-line, take a moment to understand the big picture:

- What is this feature branch trying to accomplish? Look at the commit messages and the overall shape of the changes.
- Which files are the core changes vs. supporting changes (tests, config, etc.)?
- Are there any new dependencies or significant architectural shifts?

Read the changed files in full (not just the diff hunks) when you need surrounding context to understand whether a change is correct. The diff alone can be misleading -- a function that looks fine in isolation might not make sense in the context of the whole file.

## Step 4: Review the changes

Go through each changed file and evaluate against these dimensions. Not every dimension applies to every change -- use judgment about what's relevant.

### Correctness and bugs
- Logic errors, off-by-one mistakes, wrong comparisons
- Unhandled edge cases (null/undefined, empty collections, boundary values)
- Race conditions or concurrency issues
- Error handling: are errors caught, and do they produce useful messages?
- Resource leaks (unclosed connections, missing cleanup)

### Security
- User input that flows into SQL, shell commands, or HTML without sanitization
- Hardcoded secrets, API keys, or credentials (check for these carefully)
- Authentication/authorization gaps
- Overly permissive CORS, file permissions, or network exposure

### Code quality
- Naming: do variable/function/class names communicate intent?
- Duplication: is there copy-pasted code that should be extracted?
- Complexity: are there deeply nested conditionals or functions doing too many things?
- Dead code: unused imports, unreachable branches, commented-out code
- Consistency with the existing codebase style and patterns

### Architecture and design
- Does the change fit well within the existing architecture?
- Coupling: are new dependencies between modules justified?
- Separation of concerns: is business logic mixed with I/O or presentation?
- Are abstractions at the right level -- not too clever, not too concrete?

### Test coverage
- Are the core behavioral changes covered by tests?
- Do the tests actually assert meaningful outcomes (not just "it runs without crashing")?
- Are edge cases tested?
- If no tests were added for new behavior, flag this explicitly

## Step 5: Present the review

Structure the review as follows:

### Overview
Start with a 2-3 sentence summary of what the branch does and your overall impression. Be honest but constructive. If the code is generally solid, say so. If there are significant concerns, frame them as opportunities.

### Uncommitted changes (if any)
If `git status` showed uncommitted work, mention it here briefly so the developer doesn't accidentally leave something out of the PR.

### File-by-file review

For each file that has findings, use this format:

```
### `path/to/file.ext`

**[severity] Short description of the issue**

Explain why this matters -- what could go wrong, or what improvement this enables.

The problematic code (reference the line or quote a snippet), then suggest a concrete fix or alternative approach. Use code blocks for suggestions when it helps.

---
```

**Severity levels:**
- **critical** -- Bugs, security issues, data loss risks. These should be fixed before the PR.
- **suggestion** -- Improvements to quality, readability, or robustness. Worth doing but not blocking.
- **nit** -- Minor style or preference items. Mention sparingly -- only when they genuinely improve readability.
- **praise** -- Something done well that's worth calling out. Good code reviews aren't only about problems. If a piece of the change is particularly well-crafted, say so briefly.

Use your judgment on the balance. A review that's all "critical" is overwhelming. A review that's all "nit" is unhelpful. Aim for the findings that will have the most impact on code quality.

### Summary

End with a brief summary:
- Count of findings by severity (e.g., "2 critical, 4 suggestions, 1 nit")
- The most important things to address
- An overall assessment: is this branch ready for PR after fixes, or does it need more significant rework?

## Guidelines

- **Be specific.** "This might have issues" is not helpful. "This `parseInt()` call on line 42 will return `NaN` for non-numeric input, which propagates into the price calculation" is helpful.
- **Suggest, don't just criticize.** For every problem, offer a concrete fix or direction. The goal is to make the developer's next step obvious.
- **Respect intent.** If the developer made a deliberate tradeoff (e.g., a simpler but less efficient approach), don't assume it's a mistake. Flag it as something to consider, not as an error.
- **Stay proportionate.** Don't write a paragraph about a missing semicolon. Don't dismiss a SQL injection in one line.
- **Skip the obvious.** If the code is fine, don't manufacture findings. "No issues found in this file" is a valid (and good!) outcome -- but you don't need to list every clean file. Focus your commentary where it adds value.
- **Acknowledge good work.** If a test suite is thorough, or a complex algorithm is well-commented, or error handling is exemplary, say so. It takes one line and reinforces good practices.
