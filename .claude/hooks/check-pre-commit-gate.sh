#!/bin/bash
# Hook: PostToolUse on Bash — Remind to run quality gate before commit
# Enforces: check → auto-fix → re-check flow from WORKFLOW.md

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only trigger on git commit commands
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

cat >&2 <<'EOF'

[Hook] Pre-commit quality gate reminder:

Before committing, ensure you have run:
1. `check` skill — detect lint, format, type, and security issues
2. `auto-fix` skill — apply safe automatic fixes
3. Re-run `check` — confirm clean
4. Secrets scan — no API keys, tokens, or .env values in source

If all checks passed, proceed with the commit.

EOF

exit 0
