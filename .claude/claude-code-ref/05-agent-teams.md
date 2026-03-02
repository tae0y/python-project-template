# Agent Teams

Agent Teams are an experimental orchestration mode where multiple Claude Code sessions
run as separate instances, each with its own context window, and communicate directly
with each other via messaging and a shared task list.

This is distinct from subagents. Subagents are spawned within your session via the Agent tool
and can only report back to you — they cannot message each other. Agent teammates are
peers: they share findings, challenge each other's conclusions, and coordinate without
routing everything through the lead.

## How it works

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
