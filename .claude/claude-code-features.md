
# Claude Code Features

This section explains the architectural building blocks available in Claude Code.
Read this to understand what each component is, when it applies, and how to reason about it.

---

## CLAUDE.md

CLAUDE.md is Claude Code's persistent project memory. It loads automatically at session start
and survives `/clear`. Think of it as "what Claude should know" — project architecture,
coding conventions, testing standards, and workflow rules.

Claude Code also discovers nested CLAUDE.md files in subdirectories, so you can scope
instructions per module. The main CLAUDE.md lives at the project root; subdirectory files
complement it with domain-specific context.

Put stable, reusable context here, not in the conversation. If you need to pass state
between sessions, write a plan to a file and point the next session at it — a fresh session
with a written handoff beats resuming a stale context.

CLAUDE.md is "what Claude should know." settings.json is "what Claude can do."
Keep that separation clean.

---

## Commands

Commands are reusable prompt templates stored as Markdown files under `.claude/commands/`.
A user invoking `/project:<name>` is handing you a standing operating procedure.
Treat it as an authoritative instruction set for that workflow, not a suggestion.
Commands may direct you to use tools, spawn agents, or produce specific output formats.
When a command contains `$ARGUMENTS`, substitute the user's input at that placeholder.

Commands support YAML frontmatter for metadata:

```yaml
---
description: Get Dexie.js guidance with current documentation
allowed-tools: Read, Grep, Glob, WebFetch
---
```

`allowed-tools` restricts which tools the command may use.
`description` helps Claude and humans understand the command's purpose.
User-level commands in `~/.claude/commands/` are available across all projects.

---

## Hooks

Hooks are shell-level scripts that execute automatically at specific lifecycle events,
independent of your judgment. They are deterministic guards, not AI instructions.

### Hook types

There are four handler types:
- **Command hooks** (`type: "command"`): Run a shell command. Input arrives on stdin as JSON.
- **HTTP hooks** (`type: "http"`): POST the event JSON to a URL endpoint.
- **Prompt hooks** (`type: "prompt"`): Inject an LLM prompt at the event point.
- **MCP tool hooks**: Match MCP tools using the pattern `mcp__<server>__<tool>` with regex.

### Lifecycle events

| Event              | Supports matcher | Purpose                                        |
|--------------------|:----------------:|------------------------------------------------|
| `PreToolUse`       | Yes              | Gate before a tool call. Non-zero exit = block. |
| `PostToolUse`      | Yes              | Side effects after a tool call (lint, format).  |
| `PostToolUseFailure` | Yes            | React to tool failures.                         |
| `PermissionRequest`| Yes              | Intercept permission prompts.                   |
| `UserPromptSubmit` | No               | Fires on every user message.                    |
| `Stop`             | No               | Fires when Claude finishes a response.          |
| `TeammateIdle`     | No               | Agent Teams: teammate has no work.              |
| `TaskCompleted`    | No               | A subagent task finished.                       |
| `WorktreeCreate`   | No               | Git worktree created.                           |
| `WorktreeRemove`   | No               | Git worktree removed.                           |

Events without matcher support always fire on every occurrence.

### Hook output protocol

```json
{
  "block": true,
  "message": "Reason shown to user",
  "feedback": "Non-blocking info for Claude",
  "suppressOutput": true,
  "continue": false
}
```

### Scope

Hooks can be defined in settings.json (global), in skill frontmatter (skill-scoped),
or in subagent frontmatter (agent-scoped). Skill/agent-scoped hooks only run while
that component is active.

When a hook fails, it is not an error to route around. It is a constraint to respect.

---

## Skills

Skills are domain-specific capability definitions that extend your effective knowledge
for recurring task types. Unlike commands, skills are not explicitly invoked —
they are loaded as background context and should be applied automatically when relevant.

A skill might define how to write ADRs in this project, how to handle Oracle SQL patterns,
or how to parse Korean government API responses. When the current task falls within a skill's
domain, apply its patterns without waiting to be told.

### Structure

```
.claude/skills/<skill-name>/
├── SKILL.md          # Main instructions (with optional frontmatter)
└── ...               # Supporting files (templates, examples, scripts)
```

SKILL.md can include frontmatter:

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

### Loading behavior

Claude Code loads all project skills at session start. Skills with a `description`
field are matched automatically when the conversation context is relevant.
Only SKILL.md enters the context; supporting files load on demand.
Set `disable-model-invocation: true` in frontmatter to make the skill user-invokable only.

Skills in `.claude/skills.nouse/` are disabled — they exist for reference or future activation.
Do not apply them. To enable a skill, move its directory into `.claude/skills/`.

---

## Subagents

Subagents are isolated Claude instances spawned within your session via the Task tool.
Each runs in its own context window with a custom system prompt and restricted tool access.
They report back only to you — they cannot message each other.

### Built-in subagents

| Type               | Purpose                          | Tools          | Notes                              |
|--------------------|----------------------------------|----------------|------------------------------------|
| `Explore`          | Codebase search and analysis     | Read-only      | Thoroughness: quick / medium / very thorough |
| `Plan`             | Research for plan mode           | Read-only      | Cannot spawn nested subagents       |
| `general-purpose`  | Complex multi-step tasks         | Read + Write   | Can explore and modify              |
| `claude-code-guide`| Claude Code documentation lookup | Read + Web     | Official docs reference             |

### Custom subagents

Define custom subagents as Markdown files in `.claude/agents/` (project) or
`~/.claude/agents/` (global). Frontmatter controls behavior:

```yaml
---
name: code-reviewer
description: Review code for security and style issues
tools: Read, Grep, Glob
model: sonnet
---
You are a code review specialist...
```

The `model` field routes to a specific Claude model. Set `model: inherit` to use
the main session's model. Project-level agents override global ones on name conflict.

### Key constraints

- Subagents cannot spawn other subagents (no nesting).
- Use `run_in_background: true` for tasks over ~30 seconds.
- Background tasks: press `Ctrl+B` to continue working in main session.
- Results return to your main context — many verbose subagents can still bloat it.

Subagents are for isolation and parallelism within one session.
Agent Teams are for coordination across separate sessions.

---

## Agent Teams

Agent Teams are an experimental orchestration mode where multiple Claude Code sessions
run as separate instances, each with its own context window, and communicate directly
with each other via messaging and a shared task list.

This is distinct from subagents. Subagents are spawned within your session via the Task tool
and can only report back to you — they cannot message each other. Agent teammates are
peers: they share findings, challenge each other's conclusions, and coordinate without
routing everything through the lead.

### How it works

Teams use a file-based coordination system:

```
~/.claude/teams/{team-name}/
├── config.json          # Team metadata and member list
└── inboxes/
    ├── team-lead.json
    ├── worker-1.json
    └── worker-2.json
~/.claude/tasks/{team-name}/
    ├── 1.json           # Task with status, dependencies
    └── 2.json
```

As lead, your role is to assign tasks, manage the shared task list, and synthesize output.
Use `Shift+Tab` to restrict yourself to coordination-only mode when the session calls for it.
Agent Teams consume tokens multiplicatively — scope tasks accordingly and use `--max-turns`
to control depth.

Enable with: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true`

---

## MCP (Model Context Protocol)

MCP servers are external tool providers configured in `.mcp.json` (project root, committable)
or in settings files (user/local scope).
They extend your available tools beyond the local filesystem — into live APIs,
databases, or custom business logic.

MCP tools appear alongside built-in tools (Read, Write, Bash) and are called the same way.
Tool names follow the pattern `mcp__<server>__<tool>`.
When an MCP server is configured for this project, treat its tools as first-class options,
not fallbacks. If a task involves live external data and an MCP tool covers it,
prefer that over approximating with local tools or your training knowledge.

### Token cost awareness

Each MCP server's tool descriptions consume context tokens. With many servers active,
your effective context can drop from ~200K to ~70K. Tool Search (v2.1.7+) mitigates this
by dynamically loading tool definitions only when relevant, but the cost is still real.
Monitor with `/context` and remove unused servers.

MCP servers expose their own tools — they do not inherit Claude's built-in Read/Write/Bash
unless explicitly configured.

---

## Plugins

Plugins are distributable bundles that package commands, agents, skills, hooks,
and MCP configurations into a single installable unit.

### Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata (name, version, description)
├── commands/             # Slash commands (optional)
├── agents/               # Specialized subagents (optional)
├── skills/               # Skills (optional)
├── hooks/                # Event handlers (optional)
├── .mcp.json             # MCP server config (optional)
└── README.md
```

### Installation

```bash
# From marketplace
/plugin marketplace add <owner>/<repo>
/plugin install <plugin-name>

# Manual
# Clone into project or global .claude directory
```

Plugins cannot distribute rules (permissions) automatically.
Review any plugin's hooks and scripts before installation — they run code on your machine.

---

## Settings Hierarchy

Claude Code uses a layered configuration system. Higher-priority scopes override lower ones.
Array-valued settings (permissions.allow, etc.) merge additively across scopes.

### Precedence (highest → lowest)

1. **Managed** (enterprise) — MDM profiles, registry keys, managed-settings.json
2. **Project local** — `.claude/settings.local.json` (gitignored, personal overrides)
3. **Project shared** — `.claude/settings.json` (committed, team-wide)
4. **User global** — `~/.claude/settings.json` (personal defaults)
5. **Legacy** — `~/.claude.json` (deprecated, still read)

### Key settings areas

- `model`: Default model selection (opus, sonnet, haiku)
- `permissions`: allow / ask / deny rules for tools. Deny is checked first.
- `hooks`: Lifecycle event handlers
- `env`: Environment variables applied at session start
- `sandbox`: Filesystem and network isolation settings
- `disallowedTools`: Completely block specific tools
- `enableAllProjectMcpServers`: Default false — prevents malicious MCP from committed repos

### Permission rule evaluation

Deny → Ask → Allow, first match wins. Wildcard patterns match simple prefixes only.
Compound shell operators (`&&`, `||`, `|`, `;`, `>`, `$()`) in Bash commands
require explicit allow or wrapper scripts.

---

## Context Management

Claude Code operates within a ~200K token context window (up to 1M on premium plans).
Every message, file read, and tool output consumes context. When it fills,
quality degrades and earlier decisions are lost.

### Strategies

- **Auto-compaction**: Triggers at a configurable threshold (default ~95%).
  Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., "50" for earlier compaction).
- **Strategic compaction**: Use `/compact` at logical breakpoints rather than relying
  on auto-compaction at capacity.
- **Subagent delegation**: Verbose operations (tests, log parsing, doc fetching)
  belong in subagents — only summaries return to main context.
- **Model routing**: Use Haiku subagents for exploration (cheap, fast),
  Sonnet for implementation, Opus for complex reasoning.
- **MAX_THINKING_TOKENS**: Cap extended thinking tokens to control cost
  (e.g., "10000").

### Session continuity

- `claude --continue`: Resume last session.
- `claude --resume`: Choose from recent sessions.
- Fresh session with written handoff file is usually better than resuming stale context.

---

## Sandbox

Claude Code's native sandbox provides OS-level filesystem and network isolation
(Seatbelt on macOS, bubblewrap on Linux). Enable with `/sandbox` in a session.

### Behavior

- Writes restricted to current working directory and subdirectories.
- Reads unrestricted by default — harden with explicit deny rules in settings.
- Network limited to explicitly allowed domains.
- In auto-allow mode, Bash commands within sandbox boundaries skip permission prompts.

### Important distinction

Without `/sandbox`, deny rules only block Claude's built-in tools — Bash commands
bypass them. With sandbox enabled, deny rules are enforced at the OS level,
covering Bash as well.

Hooks are guardrails (prompt-level). Sandbox is walls (OS-level).
Use both for defense in depth.
