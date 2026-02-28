#!/usr/bin/env bash
# List sentinel experience IDs not yet imported into learn.sentinel.md
# Usage: list_new_experiences.sh [localdocs_path]
# Output: one experience ID per line (only new ones)

set -euo pipefail

LEARN_FILE="${1:-localdocs/learn.sentinel.md}"

# Get all confirmed experience IDs from sentinel
ALL_IDS=$(sentinel list 2>/dev/null | grep '^ID: ' | sed 's/^ID: //' || true)

if [ -z "$ALL_IDS" ]; then
  exit 0
fi

# Get already-imported IDs from learn file
if [ -f "$LEARN_FILE" ]; then
  IMPORTED_IDS=$(grep -oP '(?<=\*\*ID:\*\* `)[^`]+' "$LEARN_FILE" 2>/dev/null || true)
else
  IMPORTED_IDS=""
fi

# Output only new IDs
while IFS= read -r id; do
  if ! echo "$IMPORTED_IDS" | grep -qF "$id"; then
    echo "$id"
  fi
done <<< "$ALL_IDS"
