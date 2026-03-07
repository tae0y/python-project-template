# .claude/ — Claude Code Configuration

## First-Time Setup

```bash
uv sync                    # Install dependencies
pre-commit install         # Install git hooks
mkdir -p localdocs/adr     # Create local docs directory
touch localdocs/worklog.todo.md localdocs/worklog.doing.md localdocs/worklog.done.md
```

## Component Types

| Type | Location | Loaded | Purpose |
|------|----------|--------|---------|
| **Rules** | `rules/` | Always (every message) | Coding standards, commit convention, thinking guidelines |
| **Skills** | `skills/` | On trigger or invocation | Procedural workflows (TDD, planning, check, etc.) |
| **Agents** | `agents/` | On spawn via Agent tool | Specialized subprocesses (tdd-guardian, learn, adr, etc.) |
| **Hooks** | `hooks/` | On tool use events | Lightweight enforcement (new test file check, external lib audit) |
| **Commands** | `commands/` | On `/project:` invocation | User-invocable shortcuts |

## Workflow Overview

See [WORKFLOW.md](WORKFLOW.md) for the full trigger map and execution flow.

## Disabled Components

Components in `*.nouse/` directories are inactive. To enable, move into the corresponding active directory.

- `skills.nouse/` — [index](skills.nouse/README.md)
- `commands.nouse/` — [index](commands.nouse/README.md)
- `hooks.nouse/` — hooks pending activation

## Knowledge Store Hierarchy

1. **During work** — `localdocs/learn.*.md` (local, not committed)
2. **At feature end** — merge to `CLAUDE.md` via `learn` agent
3. **Auto memory** — cross-project patterns only (`~/.claude/projects/`)
