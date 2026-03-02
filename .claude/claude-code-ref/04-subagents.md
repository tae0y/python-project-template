# Subagents

Subagents are isolated Claude instances spawned within your session via the Agent tool.
Each runs in its own context window with a custom system prompt and restricted tool access.
They report back only to you — they cannot message each other.

## Built-in subagents

| Type               | Model    | Tools          | Purpose                                      |
|--------------------|----------|----------------|----------------------------------------------|
| `Explore`          | Haiku    | Read-only      | Codebase search and analysis. Thoroughness: quick/medium/very thorough |
| `Plan`             | Inherits | Read-only      | Research for plan mode. Cannot spawn nested subagents |
| `general-purpose`  | Inherits | All tools      | Complex multi-step tasks                     |
| `Bash`             | Inherits | Bash           | Terminal commands in separate context         |
| `Claude Code Guide`| Haiku    | Read + Web     | Claude Code documentation lookup              |
| `statusline-setup` | Sonnet   | Read + Edit    | Status line configuration                     |

## Custom subagents

Define custom subagents as Markdown files in `.claude/agents/` (project) or
`~/.claude/agents/` (global), or use `/agents` to create interactively.

```yaml
---
name: code-reviewer
description: Review code for security and style issues
tools: Read, Grep, Glob
disallowedTools: Write, Edit
model: sonnet
permissionMode: default
maxTurns: 20
skills:
  - api-conventions
mcpServers:
  - slack
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
memory: user
background: false
isolation: worktree
---
You are a code review specialist...
```

### Supported frontmatter fields

| Field             | Required | Description                                                  |
|-------------------|:--------:|--------------------------------------------------------------|
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                       |
| `description`     | Yes      | When Claude should delegate to this subagent                 |
| `tools`           | No       | Tools the subagent can use. Inherits all if omitted          |
| `disallowedTools` | No       | Tools to deny                                                |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default)            |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns`        | No       | Maximum agentic turns                                        |
| `skills`          | No       | Skills to preload (full content injected at startup)         |
| `mcpServers`      | No       | MCP servers available to this subagent                       |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                      |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`       |
| `background`      | No       | `true` to always run as background task                      |
| `isolation`       | No       | `worktree` for isolated git worktree                         |

## Scope precedence (highest → lowest)

1. `--agents` CLI flag (current session only, JSON)
2. `.claude/agents/` (current project)
3. `~/.claude/agents/` (all projects)
4. Plugin `agents/` directory

## Key features

- **Persistent memory**: Set `memory: user|project|local` for cross-session learning.
  The subagent gets a persistent directory at `~/.claude/agent-memory/<name>/`.
- **Skill preloading**: `skills` field injects full skill content at startup.
- **Isolation**: `isolation: worktree` runs in a temporary git worktree.
- **Background execution**: `background: true` or press `Ctrl+B` to run concurrently.
- **Resumable**: Each invocation gets an agent ID; ask Claude to resume for continuity.
- **Auto-compaction**: Subagents compact at ~95% capacity (configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`).

## Key constraints

- Subagents cannot spawn other subagents (no nesting).
- Use `run_in_background: true` for tasks over ~30 seconds.
- Background tasks: press `Ctrl+B` to continue working in main session.
- Results return to your main context — many verbose subagents can still bloat it.
- Disable specific subagents: add `Agent(name)` to `permissions.deny` in settings.
- Restrict spawning: use `Agent(worker, researcher)` in `tools` field to allowlist.

Subagents are for isolation and parallelism within one session.
Agent Teams are for coordination across separate sessions.
