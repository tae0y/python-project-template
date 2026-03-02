# Hooks

Hooks are user-defined handlers that execute automatically at specific lifecycle events,
independent of Claude's judgment. They are deterministic guards, not AI instructions.

## Hook types

There are four handler types:
- **Command hooks** (`type: "command"`): Run a shell command. Input arrives on stdin as JSON.
- **HTTP hooks** (`type: "http"`): POST the event JSON to a URL endpoint.
- **Prompt hooks** (`type: "prompt"`): Single-turn LLM evaluation returning yes/no decision.
- **Agent hooks** (`type: "agent"`): Multi-turn agentic verifier with tool access (Read, Grep, Glob).

## Lifecycle events

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

## Hook handler fields

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

## Hook output protocol

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

## MCP tool matching

MCP tools follow naming `mcp__<server>__<tool>`. Use regex matchers:
- `mcp__memory__.*` — all tools from memory server
- `mcp__.*__write.*` — write tools from any server

## Scope

Hooks can be defined in:
- `~/.claude/settings.json` — all your projects
- `.claude/settings.json` — single project (committable)
- `.claude/settings.local.json` — single project (gitignored)
- Plugin `hooks/hooks.json` — when plugin is enabled
- Skill/agent frontmatter — while that component is active

Use `/hooks` in Claude Code to manage hooks interactively.
`disableAllHooks: true` in settings disables all hooks.

When a hook fails, it is not an error to route around. It is a constraint to respect.
