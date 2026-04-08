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
