#!/bin/bash
# Hook: PostToolUse — Remind to verify external library constraints
# Pattern 3: External constraints must be verified before implementing

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [[ "$FILE_PATH" != *.py ]]; then
  exit 0
fi

NEW_IMPORTS=$(echo "$CONTENT" | grep -E '^(import |from .+ import )' | grep -v '^#')

if [[ -z "$NEW_IMPORTS" ]]; then
  exit 0
fi

EXTERNAL=$(echo "$NEW_IMPORTS" | grep -vE '^(import (os|sys|re|json|math|time|datetime|pathlib|typing|collections|functools|itertools|logging|unittest|abc|io|copy|enum|dataclasses)|from (os|sys|re|json|math|time|datetime|pathlib|typing|collections|functools|itertools|logging|unittest|abc|io|copy|enum|dataclasses|\.))' )

if [[ -z "$EXTERNAL" ]]; then
  exit 0
fi

echo "[Hook] External library import detected:" >&2
echo "$EXTERNAL" >&2
cat >&2 <<'EOF'

Before proceeding:
- Have you checked the official docs or used context7/microsoft-learn for this library?
- Are there known limitations or version-specific behaviors to be aware of?
- Do not rely on training knowledge alone — verify against official documentation.

After adding a new dependency:
- Run `audit` skill to check for known vulnerabilities in updated dependencies.

(This is a reminder, not a block. Continue if already verified.)
EOF

exit 0
