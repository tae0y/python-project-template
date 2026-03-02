#!/bin/bash
# Hook: PreToolUse — Ask user confirmation when writing a new test_*.py file
# Uses permissionDecision:"ask" to prompt the user before proceeding.
# Pattern 2: No indirect solutions — never bypass the real function under test

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [[ "$TOOL" != "Write" ]]; then
  exit 0
fi

FILENAME=$(basename "$FILE_PATH")
if [[ "$FILENAME" != test_*.py ]]; then
  exit 0
fi

# Already exists — not a new file, allow
if [[ -f "$FILE_PATH" ]]; then
  exit 0
fi

REASON=$(cat <<'MSG'
[Hook] New test file creation detected. Before approving, confirm:
1. Are you importing and calling the real function under test?
2. Have you avoided writing a separate dummy/stub that mimics its behavior?
3. Does the test exercise the same execution path as production?
A test that bypasses the real implementation is a false safety net: it passes while hiding actual bugs.
MSG
)

jq -n --arg reason "$REASON" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $reason
  }
}'
