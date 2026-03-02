# Skills

Skills are domain-specific capability definitions that extend Claude's effective knowledge
for recurring task types. They follow the [Agent Skills](https://agentskills.io) open standard.

A skill might define how to write ADRs in this project, how to handle Oracle SQL patterns,
or how to parse Korean government API responses. When the current task falls within a skill's
domain, apply its patterns without waiting to be told.

## Structure

```
.claude/skills/<skill-name>/
├── SKILL.md          # Main instructions (with optional frontmatter)
├── template.md       # Template for Claude to fill in (optional)
├── examples/         # Example output (optional)
└── scripts/          # Scripts Claude can execute (optional)
```

Skills in `.claude/commands/` still work — they support the same frontmatter.
Skills are recommended for new work since they support supporting files.

## Frontmatter reference

```yaml
---
name: my-skill
description: What this skill does and when to use it
disable-model-invocation: true   # Only user can invoke via /name
user-invocable: false            # Only Claude can invoke (background knowledge)
allowed-tools: Read, Grep, Glob  # Tools allowed without permission prompts
model: sonnet                    # Model override for this skill
context: fork                    # Run in a forked subagent context
agent: Explore                   # Which subagent type when context: fork
hooks:                           # Hooks scoped to this skill's lifecycle
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---
```

## Invocation control

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                     |
|----------------------------------|:--------------:|:-----------------:|--------------------------------------------------------------|
| (default)                        | Yes            | Yes               | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes            | No                | Description not in context, full skill loads when you invoke |
| `user-invocable: false`          | No             | Yes               | Description always in context, full skill loads when invoked |

## String substitutions

| Variable               | Description                                          |
|------------------------|------------------------------------------------------|
| `$ARGUMENTS`           | All arguments passed when invoking the skill         |
| `$ARGUMENTS[N]` / `$N` | Access specific argument by 0-based index            |
| `${CLAUDE_SESSION_ID}` | Current session ID                                   |

## Dynamic context injection

The `` !`command` `` syntax runs shell commands before skill content is sent to Claude.
Output replaces the placeholder, so Claude receives actual data.

## Bundled skills

- `/simplify` — reviews changed code for reuse, quality, efficiency; spawns 3 parallel agents
- `/batch <instruction>` — orchestrates large-scale parallel changes across a codebase using worktrees
- `/debug [description]` — troubleshoots the current session by reading debug logs

## Where skills live

| Location   | Path                                          | Applies to                     |
|------------|-----------------------------------------------|--------------------------------|
| Enterprise | Managed settings                              | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`      | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`        | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`       | Where plugin is enabled        |
