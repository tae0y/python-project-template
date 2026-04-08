# Proposal: guard-settings-files hook

**Date:** 2026-04-04
**Source project:** TIL (20_DocHub/TIL)
**Category:** hook
**Status:** applied

## Summary

A PreToolUse hook that blocks Claude from directly reading, writing, or editing `.claude/settings*.json` files during any session. This prevents Claude from accidentally (or instructably) modifying its own permission configuration mid-session, which would undermine the integrity of the permission model.

## Motivation

Claude Code's permission model relies on `settings.json` and `settings.local.json` being stable during a session. If Claude can read and modify these files, it can expand its own allowed permissions at runtime — either by instruction or by accidentally overwriting them when scaffolding files. This is especially critical in headless/cron execution where no human is watching.

The hook guards against:
- Claude writing new `allow` entries into settings during a session
- Accidental overwrite when scaffolding `.claude/` directory contents
- Instruction-following that includes "update your settings to allow X"

### Evidence from localdocs

No localdocs evidence — pattern is theoretical, derived from a security review of headless cron execution design for this project.

## Proposed Change

### Target path(s) in template

`.claude/hooks/guard-settings-files.sh`

Also register in `.claude/settings.json` under `hooks.PreToolUse`:

```json
{
  "matcher": "Write|Edit|Read|Bash",
  "hooks": [
    {
      "type": "command",
      "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/guard-settings-files.sh"
    }
  ]
}
```

### Content

```bash
#!/bin/bash
# PreToolUse: block direct access to .claude/settings*.json files in all sessions
# Exit 2 = blocking, exit 0 = allow

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

case "$TOOL" in
  Write|Edit|Read)
    TARGET=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    ;;
  Bash)
    TARGET=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    ;;
  *)
    exit 0
    ;;
esac

[[ -z "$TARGET" ]] && exit 0

if echo "$TARGET" | grep -qE '\.claude/settings[^/]*\.json'; then
  echo "[guard-settings-files] BLOCKED: $TOOL attempted to access settings file." >&2
  echo "Target: $TARGET" >&2
  exit 2
fi

exit 0
```

## Caveats

- The hook blocks `Read` as well as `Write`/`Edit`. This means Claude cannot read its own settings to explain them to the user. If read access is acceptable, remove `Read` from the case statement.
- Bash command matching uses substring search on the full command string. A command that mentions `settings.json` in a comment or echo would also be blocked. This is intentionally conservative.
- `jq` must be available on the system path.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
