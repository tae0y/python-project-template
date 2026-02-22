# Feature Guide for Claude Code

This section explains the architectural building blocks available in this project.
Read this to understand what each component is, when it applies, and how to reason about it.

## Reading Order for New Sessions

When starting a session in this project, read in this order:
1. `CLAUDE.md` (this file) — architecture overview and communication style
2. `.claude/rules/` — behavioral constraints applied to every response
3. `.claude/skills/` — domain-specific patterns loaded as background context
4. `localdocs/worklog.doing.md` — active task state (if resuming work)

---

## Commands

Commands are reusable prompt templates stored as Markdown files under `.claude/commands/`.
A user invoking `/project:<name>` is handing you a standing operating procedure.
Treat it as an authoritative instruction set for that workflow, not a suggestion.
Commands may direct you to use tools, spawn agents, or produce specific output formats.
When a command contains `$ARGUMENTS`, substitute the user's input at that placeholder.

---

## Hooks

Hooks are shell-level scripts that execute automatically at specific lifecycle events,
independent of your judgment. They are deterministic guards, not AI instructions.

`PreToolUse` runs before a tool call. If it exits non-zero, treat that as a hard block —
do not proceed with the action. `PostToolUse` runs after a tool call and typically handles
side effects like formatting or logging. `Notification` fires on session lifecycle events.

When a hook fails, it is not an error to route around. It is a constraint to respect.

---

## Skills

Skills are domain-specific capability definitions that extend your effective knowledge
for recurring task types. Unlike commands, skills are not explicitly invoked —
they are loaded as background context and should be applied automatically when relevant.

A skill might define how to write ADRs in this project, how to handle Oracle SQL patterns,
or how to parse Korean government API responses. When the current task falls within a skill's
domain, apply its patterns without waiting to be told.

Skills in `.claude/skills.nouse/` are disabled — they exist for reference or future activation.
Do not apply them. To enable a skill, move its directory into `.claude/skills/`.

---

## Agent Teams

Agent Teams are an experimental orchestration mode where multiple Claude Code sessions
run as separate instances, each with its own context window, and communicate directly
with each other via messaging and a shared task list.

This is distinct from subagents. Subagents are spawned within your session via the Task tool
and can only report back to you — they cannot message each other. Agent teammates are
peers: they share findings, challenge each other's conclusions, and coordinate without
routing everything through the lead.

As lead, your role is to assign tasks, manage the shared task list, and synthesize output.
Use `Shift+Tab` to restrict yourself to coordination-only mode when the session calls for it.
Agent Teams consume tokens multiplicatively — scope tasks accordingly and use `--max-turns`
to control depth.

---

## MCP (Model Context Protocol)

MCP servers are external tool providers configured in `.claude/settings.json`.
They extend your available tools beyond the local filesystem — into live APIs,
databases, or custom business logic.

MCP tools appear alongside built-in tools (Read, Write, Bash) and are called the same way.
When an MCP server is configured for this project, treat its tools as first-class options,
not fallbacks. If a task involves live external data and an MCP tool covers it,
prefer that over approximating with local tools or your training knowledge.

---

## Communication and Reasoning Style

- Respond in Korean (해요/어요 체). Concise and analytical. Code, commits, and structured output remain in English.
- State the conclusion first. Separate facts from assumptions.
- Before answering complex questions, decompose into facts, assumptions, and preferences.
- Frame conclusions affirmatively ("It is B") before addressing alternatives.
- No praise, filler, or emojis.