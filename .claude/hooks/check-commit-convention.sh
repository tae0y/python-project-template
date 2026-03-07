#!/bin/bash
# PostToolUse: enforce commit message convention (exit 2, blocking in Claude sessions)
# Note: pre-commit hook (commit-msg stage) provides hard enforcement for all other commit sources.
# Run: pre-commit install --hook-type commit-msg
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
[[ "$TOOL" != "Bash" ]] && exit 0
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
echo "$COMMAND" | grep -q 'git commit' || exit 0
MSG=$(git log -1 --format='%s' 2>/dev/null)
[[ -z "$MSG" ]] && exit 0
if ! echo "$MSG" | grep -qE '^\[(MAINTENANCE|NEW FEATURE|BREAKING CHANGES)\]'; then
  echo "[Hook] Commit message does not follow convention: \"$MSG\"" >&2
  echo "Expected prefix: [MAINTENANCE], [NEW FEATURE], or [BREAKING CHANGES]" >&2
  echo "Fix: git commit --amend -m \"[PREFIX] $MSG\"" >&2
  exit 2
fi
exit 0
