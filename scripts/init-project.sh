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

# ── 2. Preview what will be deleted ─────────────────────────────────────────
echo "The following will be deleted:"
echo ""
for dir in localdocs proposals resources docs; do
    [[ -e "$ROOT/$dir" ]] && echo "  $dir/"
done
find "$ROOT/.claude" -maxdepth 1 \( -name "*.nouse" -o -name "claude-code-ref" \) -type d \
    | while read -r d; do echo "  .claude/$(basename "$d")/"; done
[[ -f "$ROOT/.claude/settings.local.json" ]] && echo "  .claude/settings.local.json"
find "$ROOT" -not -path "*/.git/*" -not -path "*/.venv/*" -name ".gitkeep" -type f \
    | while read -r f; do echo "  ${f#$ROOT/}"; done
for cache in .venv __pycache__ .pytest_cache .ruff_cache .mypy_cache dist build; do
    find "$ROOT" -not -path "*/.git/*" -name "$cache" \( -type d -o -type f \) 2>/dev/null \
        | while read -r p; do echo "  ${p#$ROOT/}"; done
done
find "$ROOT" -not -path "*/.git/*" -name "*.egg-info" -type d 2>/dev/null \
    | while read -r p; do echo "  ${p#$ROOT/}"; done
echo ""
read -rp "Continue? [y/N] " CONFIRM
if [[ "${CONFIRM,,}" != "y" ]]; then
    echo "Aborted."
    exit 0
fi
echo ""

# ── 3. Remove template-only directories and reset files ─────────────────────
echo "[1/5] Removing template-only directories..."
for dir in localdocs proposals resources docs; do
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

# Remove claude-code-ref directories under .claude/
find "$ROOT/.claude" -maxdepth 1 -name "claude-code-ref" -type d | while read -r d; do
    rm -rf "$d"
    echo "  removed  .claude/$(basename "$d")/"
done

# Remove settings.local.json
if [[ -f "$ROOT/.claude/settings.local.json" ]]; then
    rm -f "$ROOT/.claude/settings.local.json"
    echo "  removed  .claude/settings.local.json"
fi

# Overwrite settings.json with settings.sample.json
if [[ -f "$ROOT/.claude/settings.sample.json" ]]; then
    cp "$ROOT/.claude/settings.sample.json" "$ROOT/.claude/settings.json"
    echo "  copied   .claude/settings.sample.json → settings.json"
fi

# ── 4. Remove .gitkeep files ─────────────────────────────────────────────────
echo "[2/5] Removing .gitkeep files..."
find "$ROOT" \
    -not -path "*/.git/*" \
    -not -path "*/.venv/*" \
    -name ".gitkeep" \
    -type f \
    -print \
    -delete \
    | sed 's|^|  removed  |'

# ── 5. Remove cache and build artifacts ──────────────────────────────────────
echo "[3/5] Removing cache and build artifacts..."
for cache in .venv __pycache__ .pytest_cache .ruff_cache .mypy_cache dist build; do
    find "$ROOT" -not -path "*/.git/*" -name "$cache" \( -type d -o -type f \) 2>/dev/null \
        | while read -r p; do
            rm -rf "$p"
            echo "  removed  ${p#$ROOT/}"
        done
done
find "$ROOT" -not -path "*/.git/*" -name "*.egg-info" -type d 2>/dev/null \
    | while read -r p; do
        rm -rf "$p"
        echo "  removed  ${p#$ROOT/}"
    done

# ── 6. Rename coverage/test source path in pyproject.toml ───────────────────
echo "[4/5] Updating pyproject.toml..."
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

# ── 7. Reset README.md ──────────────────────────────────────────────────────
echo "[5/5] Resetting README.md..."
README="$ROOT/README.md"
printf "# %s\n" "$PROJECT_NAME" > "$README"
echo "  README.md reset to H1 title only"

# ── 8. Bootstrap localdocs ───────────────────────────────────────────────────
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
