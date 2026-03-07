---
name: template-downstream
description: Update .claude/, .mcp.json, and .pre-commit-config.yaml from the upstream python-project-template repository into the current project. Only files that exist upstream are updated — project-only files are never deleted. Use when pulling latest tooling, rules, hooks, or skills from the canonical template into this project. Triggers on: "템플릿 최신화", "template sync", "upstream 반영", "template 업데이트".
---

# template-downstream

Direction: Template → Project. Apply only the files that exist upstream to the current project.

**Strategy: diff-aware update, not full overwrite.**
- Files present upstream → update if content differs
- Files only in project → leave untouched (preserve project customizations)
- Files removed from upstream → do not auto-delete; report to user only

> Why not git submodule: `.claude/` requires per-project customization. Submodules force all-or-nothing application of upstream changes and cannot preserve project-local files selectively.

## Source Resolution

Resolve `TEMPLATE_ROOT` in this priority order:

1. **User-provided path** — ask the user: "Do you have a local clone of the template repo? If yes, provide the path." If provided and `<path>/.claude/` exists, use its parent as `TEMPLATE_ROOT`. No network required.
2. **Same remote** — if the current project's `origin` matches `https://github.com/tae0y/python-project-template.git`, use the local repo directly.
3. **Shallow clone** — otherwise, clone to a temp directory:

```bash
TMPDIR=$(mktemp -d)
git clone --depth 1 https://github.com/tae0y/python-project-template.git "$TMPDIR/template"
TEMPLATE_ROOT="$TMPDIR/template"
```

After resolution, verify `$TEMPLATE_ROOT/.claude/` exists. Abort if not.

## Scope

| Item | Strategy |
|------|----------|
| `.claude/` | Update upstream files only (preserve project-only files) |
| `.mcp.json` | Update if upstream has it; skip otherwise |
| `.pre-commit-config.yaml` | Update if upstream has it; skip otherwise |

**Never overwrite:**
- `.claude/settings.local.json` (local environment settings)
- `env` block inside `.claude/settings.json` (project-specific env vars)
- `localdocs/` (local-only, gitignored)
- `.env*` (secrets)

## Steps

Stop immediately on any failure. Report the cause before proceeding.

### 1. Resolve TEMPLATE_ROOT

Follow the priority order in Source Resolution above. Report which source was used.

### 2. Check working tree

If there are uncommitted changes, stop:

```
Uncommitted changes detected. Commit or stash before syncing.
```

### 3. Compute diff

Compare each upstream file against the current project:

```bash
# Files present in upstream
find "$TEMPLATE_ROOT/.claude" -type f | while read src; do
  rel="${src#$TEMPLATE_ROOT/}"
  dst="$PROJECT_ROOT/$rel"
  if [ ! -f "$dst" ]; then
    echo "NEW: $rel"
  elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
    echo "CHANGED: $rel"
  fi
done

# Files only in project (report only, do not delete)
find "$PROJECT_ROOT/.claude" -type f | while read dst; do
  rel="${dst#$PROJECT_ROOT/}"
  src="$TEMPLATE_ROOT/$rel"
  [ ! -f "$src" ] && echo "PROJECT-ONLY: $rel"
done
```

If no changes found:
```
Already up to date. No changes detected.
```
Stop.

### 4. Report and confirm

```
Files to update:
  NEW:     .claude/rules/new-rule.md
  CHANGED: .claude/rules/coding-guidelines.md
           .claude/hooks/check-commit-convention.sh

Project-only files (preserved, not deleted):
  PROJECT-ONLY: .claude/skills/my-custom-skill/SKILL.md

Proceed? (Y/N)
```

N → cleanup and exit.

### 5. Apply updates

Copy only NEW/CHANGED files. Skip `settings.local.json`.

```bash
for rel in $TO_UPDATE; do
  [[ "$rel" == *"settings.local.json"* ]] && continue
  mkdir -p "$(dirname "$PROJECT_ROOT/$rel")"
  cp "$TEMPLATE_ROOT/$rel" "$PROJECT_ROOT/$rel"
done

[ -f "$TEMPLATE_ROOT/.mcp.json" ] && \
  ! diff -q "$TEMPLATE_ROOT/.mcp.json" "$PROJECT_ROOT/.mcp.json" > /dev/null 2>&1 && \
  cp "$TEMPLATE_ROOT/.mcp.json" "$PROJECT_ROOT/.mcp.json"

[ -f "$TEMPLATE_ROOT/.pre-commit-config.yaml" ] && \
  ! diff -q "$TEMPLATE_ROOT/.pre-commit-config.yaml" "$PROJECT_ROOT/.pre-commit-config.yaml" > /dev/null 2>&1 && \
  cp "$TEMPLATE_ROOT/.pre-commit-config.yaml" "$PROJECT_ROOT/.pre-commit-config.yaml"
```

### 6. Cleanup

Only if a temp clone was created:

```bash
rm -rf "$TMPDIR"
```

### 7. Report result

```bash
git diff --stat
git status --short
```

If `.pre-commit-config.yaml` changed:

```
pre-commit config updated.
Re-install: pre-commit install --hook-type commit-msg
```

### 8. Next action

```
Update complete. Changes are unstaged.

A) Review diffs file by file
B) Stage and commit with [MAINTENANCE] prefix
C) Discard all changes (git checkout -- .)
```

Wait for user choice before proceeding.
