---
name: debugging
description: Systematic debugging methodology for identifying and fixing bugs. Load when troubleshooting errors, unexpected behavior, failing tests, or performance issues.
---

# Debugging Methodology

A systematic approach to identifying and resolving bugs.

## The Debugging Loop

```
┌─────────────────────────────────────────────────┐
│  1. REPRODUCE → 2. HYPOTHESIZE → 3. INVESTIGATE │
│        ↑                                ↓       │
│        └────── 5. VERIFY ← 4. FIX ──────┘       │
└─────────────────────────────────────────────────┘
```

## Step 1: Reproduce

Before investigating, confirm you can trigger the bug:

| Task | Command/Action |
|------|----------------|
| Run failing test | `npm test -- --grep "test name"` |
| Reproduce error | Execute the exact steps from the report |
| Check logs | Find the error message and stack trace |
| Note conditions | Environment, input data, timing |

**If you can't reproduce it, gather more information before proceeding.**

## Step 2: Hypothesize

Form 2-3 hypotheses ranked by likelihood:

```markdown
## Hypotheses

1. **Most likely**: [Description] - because [evidence]
2. **Possible**: [Description] - because [evidence]  
3. **Less likely**: [Description] - would explain [symptom]
```

Base hypotheses on:
- Error message and stack trace
- Recent changes to the code
- Similar past bugs
- The specific symptoms reported

## Step 3: Investigate

Test hypotheses systematically, starting with most likely:

### Read the Stack Trace

```
Error: Cannot read property 'name' of undefined
    at getUserName (src/user.js:42:15)      ← Start here
    at processUsers (src/process.js:18:10)
    at main (src/index.js:5:3)
```

### Trace Data Flow

Follow the data from input to error point:

1. What calls the failing function?
2. What are the actual argument values?
3. Where does the unexpected value originate?

### Add Strategic Logging

```javascript
// Temporary debug logging
console.log('[DEBUG] user object:', JSON.stringify(user, null, 2));
console.log('[DEBUG] user type:', typeof user);
console.log('[DEBUG] user keys:', user ? Object.keys(user) : 'null/undefined');
```

### Check Boundaries

Common failure points:
- Array access (empty arrays, off-by-one)
- Null/undefined values
- Async timing (race conditions)
- Type mismatches
- Edge cases (zero, empty string, special characters)

## Step 4: Fix

Once root cause is identified:

1. **Fix the immediate issue**
2. **Consider related code** - same bug pattern elsewhere?
3. **Add defensive code** if appropriate:

```javascript
// Before: crashes if user is undefined
const name = user.name;

// After: handles missing data
const name = user?.name ?? 'Unknown';
```

## Step 5: Verify

Confirm the fix works and doesn't break other things:

| Check | How |
|-------|-----|
| Original bug | Re-run the exact reproduction steps |
| Related tests | Run the test suite for affected modules |
| Edge cases | Test boundary conditions |
| Full suite | Run complete test suite if quick enough |

## Common Bug Patterns

| Symptom | Likely Cause |
|---------|--------------|
| "undefined is not a function" | Missing import, typo, wrong `this` context |
| "Cannot read property of undefined" | Null reference, missing data, async timing |
| "Maximum call stack exceeded" | Infinite recursion, circular reference |
| Works locally, fails in CI | Environment difference, missing dependency |
| Intermittent failures | Race condition, timing issue, external dependency |
| Works first time, fails on retry | State not reset, cached data, mutation |

## Debugging Commands

| Task | Command |
|------|---------|
| Node.js debugging | `node --inspect-brk script.js` |
| Python debugging | `python -m pdb script.py` |
| Check recent changes | `git log --oneline -20` |
| Find when bug introduced | `git bisect start && git bisect bad && git bisect good <commit>` |
| See what changed in file | `git log -p --follow -- path/to/file` |

## Anti-Patterns to Avoid

- **Shotgun debugging**: Making random changes hoping something works
- **Skipping reproduction**: Fixing what you assume is wrong
- **Ignoring the stack trace**: The answer is often right there
- **Not verifying**: Assuming the fix works without testing
- **Fixing symptoms**: Addressing the error without finding root cause

## Checklist

```
- [ ] Can reproduce the bug consistently
- [ ] Identified the root cause (not just symptoms)
- [ ] Fix addresses the root cause
- [ ] Original bug no longer occurs
- [ ] No new test failures introduced
- [ ] Removed debug logging before committing
```
