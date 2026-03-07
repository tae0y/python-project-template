---
name: template-broadcast
description: Apply template-downstream to all registered downstream projects in bulk, one project at a time. Use when you want to push the latest .claude/, .mcp.json, or .pre-commit-config.yaml to every project at once. Triggers on: "일괄 배포", "전체 프로젝트에 내려보내기", "모든 프로젝트 업데이트", "broadcast template", "bulk sync".
---

# template-broadcast

Apply `template-downstream` logic to every registered downstream project sequentially.
The project registry is in [references/projects.md](references/projects.md) — read it first.

## Strategy

Same merge-aware update as `template-downstream`:
- NEW files → copy as-is
- CHANGED files → **merge, not overwrite** (see `template-downstream` Merge Rules)
- Project-only files are preserved
- No auto-delete

Each project is treated independently. A failure in one project does not stop the others — report and continue.

## Steps

### 1. Read project registry

Read `references/projects.md` to get the list of active downstream projects and their local paths.

### 2. Pre-flight check for each project

For each project in the registry, verify:

```bash
# Project directory exists
[ -d "<local_path>" ] || echo "MISSING: <project>"

# No uncommitted changes
git -C "<local_path>" diff --quiet && git -C "<local_path>" diff --cached --quiet \
  || echo "DIRTY: <project> — has uncommitted changes"
```

Report pre-flight results before proceeding:

```
Pre-flight:
  real-estate-mcp         OK
  that-night-sky          DIRTY — uncommitted changes, will skip
  claude-usage-menubar    OK
  open-chat-playground    MISSING — directory not found, will skip
  claude-real-estate-openapi OK
```

Ask the user to confirm before applying:

```
Proceed with OK projects? (Y/N)
```

### 3. Resolve TEMPLATE_ROOT once

Resolve the template source once and reuse for all projects. Priority:

1. Current working directory if it is `python-template` (most common case when running from template repo)
2. `/Users/bachtaeyeong/10_SrcHub/python-template` if it exists
3. Shallow clone as fallback:

```bash
TMPDIR=$(mktemp -d)
git clone --depth 1 https://github.com/tae0y/python-project-template.git "$TMPDIR/template"
TEMPLATE_ROOT="$TMPDIR/template"
```

Verify `$TEMPLATE_ROOT/.claude/` exists. Abort all if not.

### 4. Apply to each OK project

For each project that passed pre-flight, apply the diff-aware update:

```bash
PROJECT_ROOT="<local_path>"

# Compute changed files
find "$TEMPLATE_ROOT/.claude" -type f | while read src; do
  rel="${src#$TEMPLATE_ROOT/}"
  dst="$PROJECT_ROOT/$rel"

  # If upstream file is under skills/, check if project moved it to skills.nouse/
  nouse_dst=""
  if [[ "$rel" == .claude/skills/* ]]; then
    nouse_rel="${rel/.claude\/skills\//.claude\/skills.nouse\/}"
    nouse_dst="$PROJECT_ROOT/$nouse_rel"
  fi

  if [ -n "$nouse_dst" ] && [ -f "$nouse_dst" ]; then
    # Project disabled this skill — update nouse copy instead
    if ! diff -q "$src" "$nouse_dst" > /dev/null 2>&1; then
      echo "CHANGED (nouse): $nouse_rel"
    fi
  elif [ ! -f "$dst" ]; then
    echo "NEW: $rel"
  elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
    echo "CHANGED: $rel"
  fi
done

# Apply NEW/CHANGED using merge strategy (see template-downstream Merge Rules)
# Skip settings.local.json
# For CHANGED (nouse) files, target skills.nouse/ instead of skills/
#
# NEW files → cp directly
# CHANGED files → merge by file type:
#   - JSON (.mcp.json, settings.json) → merge keys, preserve project-only keys
#   - YAML (.pre-commit-config.yaml) → merge entries, preserve project-only hooks
#   - Always-overwrite (.claude/rules/*.md, agents/*.md, WORKFLOW.md) → cp directly
#   - Other text (skills, hooks, etc.) → show diff, ask user (U/P/M), default P
```

Report per-project result immediately after each:

```
[1/3] real-estate-mcp
  CHANGED:        .claude/rules/coding-guidelines.md
  NEW:            .claude/skills/template-downstream/SKILL.md
  CHANGED (nouse): .claude/skills.nouse/tdd/SKILL.md  ← disabled by project, updating nouse copy
  unchanged: 13 files
  Done.

[2/3] claude-usage-menubar
  Already up to date.

[3/3] claude-real-estate-openapi
  CHANGED: .pre-commit-config.yaml
  Done.
```

### 5. Cleanup

If a temp clone was created:

```bash
rm -rf "$TMPDIR"
```

### 6. Final summary

```
Broadcast complete.

  applied:  3 projects
  skipped:  2 projects (dirty or missing)

Projects with .pre-commit-config.yaml changes:
  claude-real-estate-openapi — run: pre-commit install --hook-type commit-msg

Review changes in each project before committing.
```

Do not commit in any project. Leave all changes unstaged for per-project review.

## Error Handling

| Situation | Action |
|-----------|--------|
| Project directory missing | Skip, report MISSING, continue |
| Uncommitted changes in project | Skip, report DIRTY, continue |
| File copy fails | Report error for that file, continue with remaining files |
| TEMPLATE_ROOT not resolvable | Abort entire broadcast |
