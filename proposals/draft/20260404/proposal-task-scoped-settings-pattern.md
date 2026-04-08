# Proposal: task-scoped settings file pattern

**Date:** 2026-04-04
**Source project:** TIL (20_DocHub/TIL)
**Category:** config
**Status:** draft

## Summary

A pattern for creating task-specific Claude settings files (e.g., `settings.<task-name>.json`) that define a minimal, locked-down permission set for headless/cron execution. The file is passed via `--config` flag and replaces the default `settings.json` for that session only — no file swapping required.

## Motivation

When running Claude headlessly (cron, CI, scheduled agents), the default `settings.json` typically grants broad permissions suited for interactive development. For automated tasks, this is over-permissive and creates risk. The task-scoped settings pattern solves this by:

1. Defining only the permissions the task actually needs (allowlist principle)
2. Explicitly denying sensitive operations (git destructive commands, `.claude/` writes)
3. Disabling unused MCP servers to reduce attack surface
4. Using `--config <file>` so the main settings.json is never touched

This was developed as an alternative to the fragile "backup → replace → restore" pattern for settings files in cron scripts, which fails silently on error and has race conditions with concurrent sessions.

### Evidence from localdocs

No localdocs evidence — pattern emerged from a structured rethink (`/rethink-unblock`) of headless execution design. The "backup/replace/restore" anti-pattern it replaces was identified as having failure modes in error and concurrent-session scenarios.

## Proposed Change

### Target path(s) in template

`.claude/settings.<task-name>.json` (as a sample/template file)

Suggested sample name: `.claude/settings.sample-task.json`

### Content

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "mcp__passage-of-time__current_datetime",
      "mcp__passage-of-time__add_time",
      "Read(<PROJECT_ROOT>/**)",
      "Write(<PROJECT_ROOT>/<output-path>/**)",
      "Edit(<PROJECT_ROOT>/<output-path>/**)"
    ],
    "deny": [
      "Edit(<PROJECT_ROOT>/.claude/**)",
      "Write(<PROJECT_ROOT>/.claude/**)",
      "Bash(rm *)",
      "Bash(git push*)",
      "Bash(git reset*)",
      "Bash(git rebase*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|Read|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/guard-settings-files.sh"
          }
        ]
      }
    ]
  },
  "enableAllProjectMcpServers": false,
  "enabledMcpjsonServers": []
}
```

### Cron usage pattern

```bash
#!/bin/bash
# Run a scoped Claude task via cron
claude \
  --config "<PROJECT_ROOT>/.claude/settings.<task-name>.json" \
  --permission-mode bypassPermissions \
  --project-dir "<PROJECT_ROOT>" \
  -p "/<skill-name>"
```

## Caveats

- `--config` flag support should be verified for the Claude Code version in use (`claude --help | grep config`). If unsupported, fall back to HOME isolation (`HOME=/tmp/<task>-home claude ...`).
- `bypassPermissions` is needed for headless runs where no human can approve prompts. The scoped settings file compensates by narrowing the allowlist.
- `enableAllProjectMcpServers: false` disables all MCP servers unless explicitly listed. Add only servers the task actually needs.
- Pair with `guard-settings-files.sh` hook (see separate proposal) for defense-in-depth.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
