#!/usr/bin/env bash
# Initialize a new project cloned from python-template.
# Usage: bash scripts/init-project.sh [project-name]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── 1. Resolve project name ──────────────────────────────────────────────────
if [[ "${1:-}" != "" ]]; then
    PROJECT_NAME="$1"
else
    read -rp "Project name (e.g. my-awesome-project): " PROJECT_NAME
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "ERROR: project name must not be empty." >&2
    exit 1
fi

# Derive a Python-safe package name (hyphens → underscores, lowercase)
PACKAGE_NAME="$(echo "${PROJECT_NAME//-/_}" | tr '[:upper:]' '[:lower:]')"

echo ""
echo "==> Project : $PROJECT_NAME"
echo "==> Package : $PACKAGE_NAME"
echo ""

# ── 2. Remove template-only directories ─────────────────────────────────────
echo "[1/4] Removing template-only directories..."
for dir in localdocs proposals resources; do
    if [[ -e "$ROOT/$dir" ]]; then
        rm -rf "$ROOT/$dir"
        echo "  removed  $dir/"
    fi
done

# Remove *.nouse directories anywhere under .claude/
find "$ROOT/.claude" -maxdepth 1 -name "*.nouse" -type d | while read -r d; do
    rm -rf "$d"
    echo "  removed  .claude/$(basename "$d")/"
done

# Remove .arxiv directory if present
if [[ -d "$ROOT/.arxiv" ]]; then
    rm -rf "$ROOT/.arxiv"
    echo "  removed  .arxiv/"
fi

# ── 3. Remove .gitkeep files ─────────────────────────────────────────────────
echo "[2/4] Removing .gitkeep files..."
find "$ROOT" \
    -not -path "*/.git/*" \
    -not -path "*/.venv/*" \
    -name ".gitkeep" \
    -type f \
    -print \
    -delete \
    | sed 's|^|  removed  |'

# ── 4. Rename coverage/test source path in pyproject.toml ───────────────────
echo "[3/4] Updating pyproject.toml..."
TOML="$ROOT/pyproject.toml"

# project.name
sed -i '' "s|^name = \".*\"|name = \"$PROJECT_NAME\"|" "$TOML"

# project.description (placeholder)
sed -i '' "s|^description = \".*\"|description = \"$PROJECT_NAME\"|" "$TOML"

# coverage / pytest source path — replaces whatever package was there
OLD_SRC_PATTERN="src/[a-zA-Z0-9_-]+"
# pytest addopts --cov=src/<pkg>
sed -i '' -E "s|--cov=src/[a-zA-Z0-9_-]+|--cov=src/$PACKAGE_NAME|g" "$TOML"
# coverage.run source
sed -i '' -E "s|\"src/[a-zA-Z0-9_-]+\"|\"src/$PACKAGE_NAME\"|g" "$TOML"

echo "  pyproject.toml updated"

# ── 5. Update README.md title ────────────────────────────────────────────────
echo "[4/4] Updating README.md..."
README="$ROOT/README.md"
# Replace the first H1 heading with the new project name
sed -i '' "1s|^# .*|# $PROJECT_NAME|" "$README"
echo "  README.md title updated"

# ── 6. Bootstrap localdocs ───────────────────────────────────────────────────
echo ""
echo "Bootstrapping localdocs/..."
mkdir -p "$ROOT/localdocs/adr"
touch "$ROOT/localdocs/worklog.todo.md" \
      "$ROOT/localdocs/worklog.doing.md" \
      "$ROOT/localdocs/worklog.done.md"
echo "  localdocs/ created"

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Next steps:"
echo "  uv sync"
echo "  pre-commit install --hook-type commit-msg"
echo "  # Edit CLAUDE.md (see CLAUDE.sample.md for reference)"
echo "  git add -A && git commit -m '[MAINTENANCE] Initialize project from python-template'"
