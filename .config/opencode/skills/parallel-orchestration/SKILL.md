---
name: parallel-orchestration
description: Parallel task execution patterns using git worktrees. Load when decomposing work for concurrent subagents, managing isolated branches, or coordinating multi-agent workflows.
---

## What I Do

- Decompose complex tasks into parallelizable units
- Manage git worktrees for isolated concurrent work
- Coordinate subagent execution and result merging
- Handle conflicts and integration of parallel changes

## When to Parallelize

| Scenario | Parallel? | Reason |
|----------|-----------|--------|
| Independent file changes | Yes | No conflicts possible |
| Same file, different sections | Maybe | Risk of merge conflicts |
| Sequential dependencies | No | Must complete in order |
| Shared state modifications | No | Race conditions |
| Read-only analysis tasks | Yes | No side effects |

## Git Worktree Quick Reference

Use the `use-git-worktree` tool for all worktree operations. Never run `git worktree` commands directly via bash.

| Action | Tool Parameters |
|--------|-----------------|
| Create worktree | `action: "create", name: "task-name"` |
| List worktrees | `action: "list"` |
| Merge to target | `action: "merge", name: "task-name", targetBranch: "main", mergeStrategy: "theirs"` |
| Remove worktree | `action: "remove", name: "task-name"` |
| Clean stale entries | `action: "prune"` |

### Worktree Locations

```
{repoRoot}/.opencode/worktrees/{name}/    # Working directory
opencode/{name}                            # Branch name
```

### Merge Strategies

| Strategy | Behavior | Use When |
|----------|----------|----------|
| `theirs` | Prefer worktree changes | Subagent work is authoritative |
| `ours` | Prefer target branch | Target has critical updates |
| `manual` | Abort on conflict, return diff | Complex conflicts need review |

## Orchestration Patterns

### Pattern 1: Independent Tasks

Best for tasks with no file overlap.

```
1. Analyze task list for dependencies
2. Group independent tasks
3. Create worktree per task group
4. Spawn subagents with worktree paths
5. Merge results sequentially (order doesn't matter)
6. Prune worktrees
```

### Pattern 2: Feature Decomposition

Break a feature into components.

```
1. Identify feature components (API, UI, tests, docs)
2. Create worktree for each component
3. Define integration points/interfaces first
4. Execute component work in parallel
5. Merge in dependency order (API → UI → tests → docs)
6. Run integration tests on merged result
```

### Pattern 3: Batch Processing

Apply similar changes across many files.

```
1. Divide files into batches
2. Create worktree per batch
3. Apply transformation to each batch
4. Merge batches (likely conflict-free)
5. Verify combined result
```

## Subagent Coordination

### Spawning Parallel Subagents

When using the Task tool for parallel work:

1. Create worktrees BEFORE spawning subagents
2. Pass the worktree path in the prompt
3. Instruct subagent to work ONLY in that directory
4. Wait for all subagents to complete
5. Merge results in correct order

### Prompt Template for Subagents

```
Work in this git worktree: {worktree_path}

Your task: {specific_task_description}

Important:
- Only modify files within this worktree
- Commit your changes before completing
- Do not merge or push - the orchestrator handles that

Return: {expected_output_format}
```

## Conflict Prevention

### Before Parallelizing

- [ ] Map file dependencies for each task
- [ ] Identify shared files that multiple tasks touch
- [ ] Extract shared file changes into sequential pre/post steps
- [ ] Define clear boundaries for each parallel unit

### Handling Conflicts

1. **Prevention**: Structure tasks to avoid same-file edits
2. **Detection**: Use `manual` merge strategy to surface conflicts
3. **Resolution**: 
   - If mechanical: use `theirs` and verify
   - If semantic: review diff, apply manually
4. **Retry**: Re-run conflicting task with updated context

## Execution Checklist

```
[ ] Tasks analyzed for parallelization potential
[ ] Dependencies mapped and respected
[ ] Worktrees created before subagent spawn
[ ] Each subagent has isolated worktree path
[ ] Merge order matches dependency graph
[ ] Integration verified after all merges
[ ] Worktrees cleaned up with prune
```

## Anti-patterns

- **Over-parallelization**: Don't parallelize 2-minute tasks; overhead exceeds benefit
- **Shared file edits**: Multiple agents editing same file causes merge pain
- **Missing integration**: Parallel work must be verified together, not just individually
- **Orphaned worktrees**: Always prune after orchestration completes
- **Direct git commands**: Use the `use-git-worktree` tool, never `git worktree` via bash
