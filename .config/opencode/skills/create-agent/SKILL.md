---
name: create-agent
description: Create and configure OpenCode agents. Load when building custom agents, writing agent markdown files, or configuring agent tools and permissions.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
---

## What I do

- Create agent markdown files with proper frontmatter
- Configure agent modes (primary vs subagent)
- Set up tool permissions for agents
- Define custom prompts and behaviors
- Integrate skills into agents

## When to use me

Load this skill when:
- Creating a new custom agent
- Modifying agent tool permissions
- Setting up read-only or restricted agents
- Configuring subagents for specialized tasks

## Agent file locations

| Scope | Path |
|-------|------|
| Global | `~/.config/opencode/agents/<name>.md` |
| Project | `.opencode/agents/<name>.md` |

The filename becomes the agent name (e.g., `review.md` creates `review` agent).

## Required frontmatter

```yaml
---
description: Brief description of what the agent does (required)
mode: primary | subagent
---
```

## Agent modes

| Mode | Behavior |
|------|----------|
| `primary` | Main agent, switch with Tab key |
| `subagent` | Invoked by primary agents or via `@name` mention |

Default mode is `all` (both primary and subagent) if not specified.

## Tool configuration

Disable tools to create restricted agents:

```yaml
---
tools:
  write: false    # Disable file creation
  edit: false     # Disable file editing
  bash: false     # Disable shell commands
  todowrite: false # Disable todo management
  skill: false    # Disable skill loading
---
```

## Permission configuration

Fine-grained control over tool behavior:

```yaml
---
permission:
  edit: deny | ask | allow
  bash:
    "*": ask
    "git status": allow
    "git diff*": allow
  webfetch: deny
  skill:
    "*": allow
    "internal-*": deny
---
```

## Using skills in agents

Reference skills with the `{skill:name}` syntax in the prompt body:

```markdown
---
description: Code reviewer agent
mode: subagent
tools:
  write: false
  edit: false
---

{skill:code-review}
```

## Read-only agent template

```markdown
---
description: Analyzes code without making changes
mode: subagent
tools:
  write: false
  edit: false
  bash: false
---

Analyze code and provide insights. Do not suggest modifications.
```

## Full-access agent template

```markdown
---
description: Development agent with all capabilities
mode: primary
model: anthropic/claude-sonnet-4-20250514
temperature: 0.3
---

Build features, fix bugs, and refactor code.
```

## Additional options

| Option | Purpose |
|--------|---------|
| `model` | Override default model (`provider/model-id`) |
| `temperature` | Control response randomness (0.0-1.0) |
| `maxSteps` | Limit agentic iterations |
| `hidden` | Hide subagent from `@` autocomplete |
| `disable` | Disable the agent entirely |

## Subagent invocation

Primary agents invoke subagents via the Task tool based on descriptions. Users invoke manually with `@name` syntax:

```
@code-review check this function for issues
```

## Checklist

Before finalizing an agent:

- [ ] Frontmatter starts on line 1 with `---`
- [ ] `description` clearly states purpose and when to use
- [ ] `mode` is set appropriately (primary/subagent)
- [ ] Tools are configured for intended access level
- [ ] Permissions restrict dangerous operations if needed
- [ ] Prompt provides clear behavioral guidance
- [ ] Model is specified if different from default
