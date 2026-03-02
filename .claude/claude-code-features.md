
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

Auto-memory can be enabled via `/memory` to let Claude write persistent notes
to `~/.claude/projects/.../memory/MEMORY.md` automatically.

---

## Skills

Skills are domain-specific capability definitions that extend Claude's effective knowledge
for recurring task types. They follow the [Agent Skills](https://agentskills.io) open standard.

A skill might define how to write ADRs in this project, how to handle Oracle SQL patterns,
or how to parse Korean government API responses. When the current task falls within a skill's
domain, apply its patterns without waiting to be told.

### Structure

```
.claude/skills/<skill-name>/
├── SKILL.md          # Main instructions (with optional frontmatter)
├── template.md       # Template for Claude to fill in (optional)
├── examples/         # Example output (optional)
└── scripts/          # Scripts Claude can execute (optional)
```

Skills in `.claude/commands/` still work — they support the same frontmatter.
Skills are recommended for new work since they support supporting files.

### Frontmatter reference

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

### Invocation control

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                     |
|----------------------------------|:--------------:|:-----------------:|--------------------------------------------------------------|
| (default)                        | Yes            | Yes               | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes            | No                | Description not in context, full skill loads when you invoke |
| `user-invocable: false`          | No             | Yes               | Description always in context, full skill loads when invoked |

### String substitutions

| Variable               | Description                                          |
|------------------------|------------------------------------------------------|
| `$ARGUMENTS`           | All arguments passed when invoking the skill         |
| `$ARGUMENTS[N]` / `$N` | Access specific argument by 0-based index            |
| `${CLAUDE_SESSION_ID}` | Current session ID                                   |

### Dynamic context injection

The `` !`command` `` syntax runs shell commands before skill content is sent to Claude.
Output replaces the placeholder, so Claude receives actual data.

### Bundled skills

- `/simplify` — reviews changed code for reuse, quality, efficiency; spawns 3 parallel agents
- `/batch <instruction>` — orchestrates large-scale parallel changes across a codebase using worktrees
- `/debug [description]` — troubleshoots the current session by reading debug logs

### Where skills live

| Location   | Path                                          | Applies to                     |
|------------|-----------------------------------------------|--------------------------------|
| Enterprise | Managed settings                              | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md`      | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`        | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`       | Where plugin is enabled        |

---

## Hooks

Hooks are user-defined handlers that execute automatically at specific lifecycle events,
independent of Claude's judgment. They are deterministic guards, not AI instructions.

### Hook types

There are four handler types:
- **Command hooks** (`type: "command"`): Run a shell command. Input arrives on stdin as JSON.
- **HTTP hooks** (`type: "http"`): POST the event JSON to a URL endpoint.
- **Prompt hooks** (`type: "prompt"`): Single-turn LLM evaluation returning yes/no decision.
- **Agent hooks** (`type: "agent"`): Multi-turn agentic verifier with tool access (Read, Grep, Glob).

### Lifecycle events

| Event                | Supports matcher | Purpose                                                     |
|----------------------|:----------------:|-------------------------------------------------------------|
| `SessionStart`       | Yes (source)     | Session begins or resumes. Matcher: startup/resume/clear/compact |
| `UserPromptSubmit`   | No               | Fires on every user message.                                |
| `PreToolUse`         | Yes (tool name)  | Gate before a tool call. Supports allow/deny/ask.           |
| `PermissionRequest`  | Yes (tool name)  | Intercept permission prompts.                               |
| `PostToolUse`        | Yes (tool name)  | Side effects after a tool call (lint, format).              |
| `PostToolUseFailure` | Yes (tool name)  | React to tool failures.                                     |
| `Notification`       | Yes (type)       | Claude Code sends a notification.                           |
| `SubagentStart`      | Yes (agent type) | A subagent is spawned.                                      |
| `SubagentStop`       | Yes (agent type) | A subagent finishes.                                        |
| `Stop`               | No               | Claude finishes a response.                                 |
| `TeammateIdle`       | No               | Agent Teams: teammate has no work.                          |
| `TaskCompleted`      | No               | A task is being marked completed.                           |
| `ConfigChange`       | Yes (source)     | Configuration file changes during session.                  |
| `WorktreeCreate`     | No               | Git worktree created.                                       |
| `WorktreeRemove`     | No               | Git worktree removed.                                       |
| `PreCompact`         | Yes (trigger)    | Before context compaction. Matcher: manual/auto             |
| `SessionEnd`         | Yes (reason)     | Session terminates.                                         |

### Hook handler fields

Common fields for all types:

| Field           | Required | Description                                                  |
|-----------------|:--------:|--------------------------------------------------------------|
| `type`          | yes      | `"command"`, `"http"`, `"prompt"`, or `"agent"`              |
| `timeout`       | no       | Seconds before canceling (default: 600/30/60 by type)        |
| `statusMessage` | no       | Custom spinner message while hook runs                       |
| `once`          | no       | If `true`, runs only once per session (skills only)          |

Command-specific: `command` (required), `async` (optional background execution).
HTTP-specific: `url` (required), `headers` (optional), `allowedEnvVars` (optional).
Prompt/Agent-specific: `prompt` (required, use `$ARGUMENTS` for context), `model` (optional).

### Hook output protocol

Exit codes:
- **Exit 0**: Action proceeds. Stdout parsed for JSON (if any).
- **Exit 2**: Blocking error. Stderr fed back to Claude.
- **Other**: Non-blocking error. Stderr logged in verbose mode.

PreToolUse hooks support three-way decision control via JSON:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow | deny | ask",
    "permissionDecisionReason": "Reason text",
    "updatedInput": {},
    "additionalContext": "Extra context for Claude"
  }
}
```

### MCP tool matching

MCP tools follow naming `mcp__<server>__<tool>`. Use regex matchers:
- `mcp__memory__.*` — all tools from memory server
- `mcp__.*__write.*` — write tools from any server

### Scope

Hooks can be defined in:
- `~/.claude/settings.json` — all your projects
- `.claude/settings.json` — single project (committable)
- `.claude/settings.local.json` — single project (gitignored)
- Plugin `hooks/hooks.json` — when plugin is enabled
- Skill/agent frontmatter — while that component is active

Use `/hooks` in Claude Code to manage hooks interactively.
`disableAllHooks: true` in settings disables all hooks.

When a hook fails, it is not an error to route around. It is a constraint to respect.

---

## Subagents

Subagents are isolated Claude instances spawned within your session via the Agent tool.
Each runs in its own context window with a custom system prompt and restricted tool access.
They report back only to you — they cannot message each other.

### Built-in subagents

| Type               | Model    | Tools          | Purpose                                      |
|--------------------|----------|----------------|----------------------------------------------|
| `Explore`          | Haiku    | Read-only      | Codebase search and analysis. Thoroughness: quick/medium/very thorough |
| `Plan`             | Inherits | Read-only      | Research for plan mode. Cannot spawn nested subagents |
| `general-purpose`  | Inherits | All tools      | Complex multi-step tasks                     |
| `Bash`             | Inherits | Bash           | Terminal commands in separate context         |
| `Claude Code Guide`| Haiku    | Read + Web     | Claude Code documentation lookup              |
| `statusline-setup` | Sonnet   | Read + Edit    | Status line configuration                     |

### Custom subagents

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

### Subagent scope precedence (highest → lowest)

1. `--agents` CLI flag (current session only, JSON)
2. `.claude/agents/` (current project)
3. `~/.claude/agents/` (all projects)
4. Plugin `agents/` directory

### Key features

- **Persistent memory**: Set `memory: user|project|local` for cross-session learning.
  The subagent gets a persistent directory at `~/.claude/agent-memory/<name>/`.
- **Skill preloading**: `skills` field injects full skill content at startup.
- **Isolation**: `isolation: worktree` runs in a temporary git worktree.
- **Background execution**: `background: true` or press `Ctrl+B` to run concurrently.
- **Resumable**: Each invocation gets an agent ID; ask Claude to resume for continuity.
- **Auto-compaction**: Subagents compact at ~95% capacity (configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`).

### Key constraints

- Subagents cannot spawn other subagents (no nesting).
- Use `run_in_background: true` for tasks over ~30 seconds.
- Background tasks: press `Ctrl+B` to continue working in main session.
- Results return to your main context — many verbose subagents can still bloat it.
- Disable specific subagents: add `Agent(name)` to `permissions.deny` in settings.

Subagents are for isolation and parallelism within one session.
Agent Teams are for coordination across separate sessions.

---

## Agent Teams

Agent Teams are an experimental orchestration mode where multiple Claude Code sessions
run as separate instances, each with its own context window, and communicate directly
with each other via messaging and a shared task list.

This is distinct from subagents. Subagents are spawned within your session via the Agent tool
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

MCP servers are external tool providers that extend Claude Code's available tools
beyond the local filesystem — into live APIs, databases, or custom business logic.
MCP uses the [open standard](https://modelcontextprotocol.io/introduction).

### Configuration

MCP servers can be configured in three ways:
- CLI: `claude mcp add --transport http <name> <url>`
- Project: `.mcp.json` (committable, team-shared)
- Settings files (user/local/managed scope)

Supported transports: **HTTP** (recommended), **SSE** (deprecated), **stdio** (local processes).

### Installation scopes

| Scope   | Storage                      | Use case                                              |
|---------|------------------------------|-------------------------------------------------------|
| local   | `~/.claude.json` (default)   | Personal, current project only                        |
| project | `.mcp.json` (version control)| Team-shared                                           |
| user    | `~/.claude.json`             | Personal, all projects                                |
| managed | System directories           | Admin-controlled, organization-wide                   |

### Key features

- **OAuth authentication**: Use `/mcp` to authenticate with remote servers requiring OAuth 2.0.
- **MCP resources**: Reference with `@server:protocol://path` in prompts.
- **MCP prompts**: Exposed as commands: `/mcp__<server>__<prompt>`.
- **Tool Search**: Automatically enabled when MCP tool definitions exceed 10% of context.
  Dynamically loads tools on-demand instead of preloading all. Configure with `ENABLE_TOOL_SEARCH`.
- **Dynamic updates**: Servers can send `list_changed` notifications to refresh tools without reconnect.
- **Claude Code as MCP server**: `claude mcp serve` exposes Claude Code's tools to other MCP clients.
- **Plugin MCP servers**: Plugins can bundle MCP servers that start automatically when enabled.
- **Environment variable expansion**: `.mcp.json` supports `${VAR}` and `${VAR:-default}` syntax.

### Token cost awareness

Each MCP server's tool descriptions consume context tokens. With many servers active,
your effective context can drop significantly. Tool Search mitigates this
by dynamically loading tool definitions only when relevant.
Monitor with `/context` and remove unused servers.
`MAX_MCP_OUTPUT_TOKENS` (default 25,000) controls maximum output per tool call.

---

## Plugins

Plugins are distributable bundles that package skills, agents, hooks, MCP servers,
LSP servers, and commands into a single installable unit.

### Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata (name, version, description)
├── commands/             # Slash commands (legacy; use skills/ for new)
├── agents/               # Specialized subagents
├── skills/               # Skills with SKILL.md
├── hooks/
│   └── hooks.json        # Hook configurations
├── .mcp.json             # MCP server config
├── .lsp.json             # LSP server config
├── settings.json         # Default settings for the plugin
├── scripts/              # Hook and utility scripts
├── LICENSE
└── CHANGELOG.md
```

### Components

| Component     | Location             | Purpose                                        |
|---------------|----------------------|------------------------------------------------|
| Skills        | `skills/`            | Skills with `<name>/SKILL.md`                  |
| Commands      | `commands/`          | Legacy slash commands (Markdown files)          |
| Agents        | `agents/`            | Subagent Markdown files                        |
| Hooks         | `hooks/hooks.json`   | Event handler configurations                   |
| MCP servers   | `.mcp.json`          | MCP server definitions                         |
| LSP servers   | `.lsp.json`          | Language Server Protocol configurations        |
| Settings      | `settings.json`      | Default config applied when plugin is enabled  |

### LSP servers

Plugins can provide LSP (Language Server Protocol) servers for real-time code intelligence:
instant diagnostics, go-to-definition, find references, hover info, and type information.

Available LSP plugins: `pyright-lsp` (Python), `typescript-lsp` (TypeScript), `rust-lsp` (Rust).

### Installation

```bash
# From marketplace
claude plugin install <plugin-name>@<marketplace>

# Scope options: user (default), project, local
claude plugin install formatter@my-marketplace --scope project

# Management
claude plugin uninstall <plugin>
claude plugin enable <plugin>
claude plugin disable <plugin>
claude plugin update <plugin>
```

### Installation scopes

| Scope     | Settings file                    | Use case                                       |
|-----------|----------------------------------|-------------------------------------------------|
| `user`    | `~/.claude/settings.json`       | Personal, all projects (default)                |
| `project` | `.claude/settings.json`          | Team-shared via version control                 |
| `local`   | `.claude/settings.local.json`    | Project-specific, gitignored                    |
| `managed` | Managed settings                 | Admin-controlled (read-only, update only)       |

Plugins cannot distribute rules (permissions) automatically.
Review any plugin's hooks and scripts before installation — they run code on your machine.
Use `${CLAUDE_PLUGIN_ROOT}` in hooks/scripts for plugin-relative paths.

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

- `claude --continue` / `claude -c`: Resume last session.
- `claude --resume` / `claude -r`: Choose from recent sessions by ID or name.
- `claude --continue --fork-session`: Branch off from a session without modifying the original.
- Fresh session with written handoff file is usually better than resuming stale context.

---

## Checkpointing

Claude Code automatically tracks file edits, allowing you to rewind to previous states
if anything gets off track. Checkpoints are a session-level safety net.

### How it works

- Every user prompt creates a new checkpoint.
- Only tracks edits made through Claude's file editing tools (not Bash commands).
- Checkpoints persist across sessions and can be accessed in resumed conversations.
- Automatically cleaned up after 30 days (configurable).

### Rewind and summarize

Press `Esc+Esc` or use `/rewind` to open the rewind menu. Options:

- **Restore code and conversation**: revert both to that point.
- **Restore conversation**: rewind to that message while keeping current code.
- **Restore code**: revert file changes while keeping the conversation.
- **Summarize from here**: compress conversation from this point forward into a summary,
  freeing context space. Original messages stay in the transcript for reference.
- **Never mind**: return without changes.

### Limitations

- Bash command changes (rm, mv, cp) are not tracked — only direct file editing tools.
- External changes from other sessions or manual edits are not captured.
- Not a replacement for version control. Think of checkpoints as "local undo" and Git as "permanent history."

---

## Interactive Mode

### Keyboard shortcuts

#### General controls

| Shortcut            | Description                                      |
|---------------------|--------------------------------------------------|
| `Ctrl+C`           | Cancel current input or generation               |
| `Ctrl+D`           | Exit session                                     |
| `Ctrl+F`           | Kill all background agents (press twice to confirm) |
| `Ctrl+G`           | Open in default text editor                      |
| `Ctrl+L`           | Clear terminal screen (keeps conversation)       |
| `Ctrl+O`           | Toggle verbose output                            |
| `Ctrl+R`           | Reverse search command history                   |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard                       |
| `Ctrl+B`           | Background running tasks (tmux: press twice)     |
| `Ctrl+T`           | Toggle task list                                 |
| `Esc+Esc`          | Rewind / summarize                               |
| `Shift+Tab`        | Toggle permission modes                          |
| `Alt+P`            | Switch model                                     |
| `Alt+T`            | Toggle extended thinking                         |

#### Multiline input

| Method           | Shortcut       |
|------------------|----------------|
| Quick escape     | `\` + `Enter`  |
| macOS default    | `Option+Enter` |
| Shift+Enter      | `Shift+Enter` (iTerm2, WezTerm, Ghostty, Kitty natively) |
| Control sequence | `Ctrl+J`       |

#### Quick commands

| Shortcut     | Description                          |
|--------------|--------------------------------------|
| `/` at start | Command or skill                     |
| `!` at start | Bash mode (run commands directly)    |
| `@`          | File path mention / MCP resource     |

### Built-in commands (selected)

| Command             | Purpose                                              |
|---------------------|------------------------------------------------------|
| `/clear`            | Clear conversation history and free context          |
| `/compact`          | Compact conversation with optional focus instructions|
| `/config`           | Open settings interface                              |
| `/context`          | Visualize current context usage                      |
| `/cost`             | Show token usage statistics                          |
| `/diff`             | Interactive diff viewer for uncommitted changes      |
| `/doctor`           | Diagnose installation and settings                   |
| `/export`           | Export conversation as plain text                    |
| `/fast`             | Toggle fast mode                                     |
| `/fork`             | Fork current conversation                            |
| `/hooks`            | Manage hook configurations                           |
| `/init`             | Initialize project with CLAUDE.md                    |
| `/keybindings`      | Open keybindings configuration                       |
| `/mcp`              | Manage MCP server connections and OAuth              |
| `/memory`           | Edit CLAUDE.md memory files and auto-memory          |
| `/model`            | Select or change model (left/right for effort level) |
| `/output-style`     | Switch output style (Default/Explanatory/Learning)   |
| `/permissions`      | View or update permissions                           |
| `/plan`             | Enter plan mode                                      |
| `/plugin`           | Manage plugins                                       |
| `/pr-comments`      | Fetch GitHub PR comments                             |
| `/release-notes`    | View changelog                                       |
| `/resume`           | Resume a conversation by ID or name                  |
| `/review`           | Review a pull request                                |
| `/rewind`           | Rewind to checkpoint                                 |
| `/sandbox`          | Toggle sandbox mode                                  |
| `/security-review`  | Analyze pending changes for security vulnerabilities |
| `/skills`           | List available skills                                |
| `/stats`            | Visualize daily usage and session history            |
| `/tasks`            | List and manage background tasks                     |
| `/theme`            | Change color theme                                   |
| `/vim`              | Toggle vim editing mode                              |

### Vim editor mode

Enable with `/vim` or configure permanently via `/config`.
Supports NORMAL/INSERT modes, full navigation (h/j/k/l, w/e/b, gg/G, f/t),
editing (d/c/y/p, dd/cc/yy, text objects iw/aw/i"/a"/i(/a(, etc.),
and repeat with `.`.

### Prompt suggestions

After Claude responds, grayed-out suggestions appear based on conversation history.
Press `Tab` to accept, `Enter` to accept and submit.
Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

### Task list

For complex work, Claude creates a task list visible in the status area.
`Ctrl+T` toggles the view. Tasks persist across context compactions.
Share across sessions: `CLAUDE_CODE_TASK_LIST_ID=my-project claude`.

### PR review status

When on a branch with an open PR, the footer shows a clickable PR link with
colored underline: green (approved), yellow (pending), red (changes requested),
gray (draft), purple (merged).

---

## CLI Reference

### Commands

| Command                   | Description                                       |
|---------------------------|---------------------------------------------------|
| `claude`                  | Start interactive session                         |
| `claude "query"`          | Start session with initial prompt                 |
| `claude -p "query"`       | Print response without interactive mode (SDK)     |
| `cat file \| claude -p`   | Process piped content                             |
| `claude -c`               | Continue most recent conversation                 |
| `claude -r "session"`     | Resume specific session by ID or name             |
| `claude update`           | Update to latest version                          |
| `claude auth login/logout/status` | Authentication management               |
| `claude agents`           | List all configured subagents                     |
| `claude mcp`              | Configure MCP servers                             |
| `claude remote-control`   | Start Remote Control session from claude.ai       |

### Key flags

| Flag                       | Description                                       |
|----------------------------|---------------------------------------------------|
| `--model`                  | Set model (alias: sonnet, opus, haiku)            |
| `--allowedTools`           | Tools that execute without permission prompts     |
| `--disallowedTools`        | Tools removed from model's context                |
| `--permission-mode`        | Start in a specified permission mode (plan, etc.) |
| `--max-turns`              | Limit agentic turns (print mode only)             |
| `--max-budget-usd`         | Maximum dollar amount for API calls               |
| `--output-format`          | Output: text, json, stream-json                   |
| `--json-schema`            | Get validated JSON output matching a schema       |
| `--system-prompt`          | Replace entire system prompt                      |
| `--append-system-prompt`   | Append to default system prompt                   |
| `--agent`                  | Specify an agent for the session                  |
| `--agents`                 | Define subagents dynamically via JSON             |
| `--tools`                  | Restrict which built-in tools are available       |
| `--mcp-config`             | Load MCP servers from JSON files                  |
| `--worktree`, `-w`         | Start in isolated git worktree                    |
| `--add-dir`                | Add additional working directories                |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration         |
| `--remote`                 | Create a web session on claude.ai                 |
| `--teleport`               | Resume a web session locally                      |
| `--verbose`                | Enable verbose logging                            |
| `--debug`                  | Enable debug mode with category filtering         |
| `--fallback-model`         | Auto-fallback when default model is overloaded    |

### Headless / SDK usage

`claude -p` runs non-interactively (formerly "headless mode"). The Agent SDK gives
the same tools, agent loop, and context management programmatically via CLI, Python, or TypeScript.

```bash
# Structured JSON output
claude -p "Summarize this project" --output-format json

# Schema-validated output
claude -p "Extract functions" --output-format json --json-schema '{...}'

# Stream responses
claude -p "Explain" --output-format stream-json --verbose --include-partial-messages

# Auto-approve tools
claude -p "Run tests and fix failures" --allowedTools "Bash,Read,Edit"

# Continue conversation
claude -p "Focus on DB queries" --continue
```

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
