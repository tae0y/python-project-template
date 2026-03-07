---
name: template-downstream
description: Update .claude/, .mcp.json, and .pre-commit-config.yaml from the upstream python-project-template repository into the current project. Only files that exist upstream are updated — project-only files are never deleted. Use when pulling latest tooling, rules, hooks, or skills from the canonical template into this project. Triggers on: "템플릿 최신화", "template sync", "upstream 반영", "template 업데이트".
---

# template-downstream

Direction: Template → Project. Apply only the files that exist upstream to the current project.

**Strategy: merge-aware update, not full overwrite.**
- NEW files (upstream only) → copy as-is
- CHANGED files (both exist, content differs) → **merge, not overwrite** (see Merge Rules below)
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

## Merge Rules

For CHANGED files (file exists in both upstream and project with different content):

### Structured files (`.mcp.json`, `settings.json`)

Parse both as JSON. Merge keys:
- Keys present only in upstream → add
- Keys present only in project → **preserve** (project customization)
- Keys present in both with different values → **use upstream value** but report the diff to the user

For `settings.json`, never touch the `env` block — it is always project-specific.

### YAML files (`.pre-commit-config.yaml`)

Parse both as YAML. Merge entries:
- Hooks/repos present only in upstream → add
- Hooks/repos present only in project → **preserve**
- Same hook with different config → **use upstream version** but report the diff

### Markdown / text files (`.md`, `.sh`, etc.)

Read both files. Compare content:
- If the project file is **identical to a previous upstream version** (no project-specific edits) → replace with new upstream version
- If the project file has **project-specific additions or modifications** → show a side-by-side diff to the user and ask:
  - `(U)` Use upstream version (overwrite)
  - `(P)` Keep project version (skip)
  - `(M)` Manual merge — open diff for user to resolve

Default to `(P)` if the user does not respond, to avoid data loss.

### Files that are always overwritten (no merge)

- `.claude/rules/*.md` — template rules are authoritative
- `.claude/agents/*.md` — template agent configs are authoritative
- `.claude/WORKFLOW.md` — template workflow is authoritative

These files should not contain project-specific content. If a project needs custom rules, it should create separate files (e.g., `.claude/rules/project-specific.md`).

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
  NEW:            .claude/rules/new-rule.md
  CHANGED:        .claude/rules/coding-guidelines.md
                  .claude/hooks/check-commit-convention.sh
  CHANGED (nouse): .claude/skills.nouse/tdd/SKILL.md  ← disabled by project, updating nouse copy

Project-only files (preserved, not deleted):
  PROJECT-ONLY: .claude/skills/my-custom-skill/SKILL.md

Proceed? (Y/N)
```

N → cleanup and exit.

### 5. Apply updates

For each file in the update list, apply the appropriate strategy. Skip `settings.local.json`.
For `CHANGED (nouse)` files, target `skills.nouse/` instead of `skills/`.

**NEW files** → copy directly:

```bash
mkdir -p "$(dirname "$PROJECT_ROOT/$rel")"
cp "$src" "$PROJECT_ROOT/$rel"
```

**CHANGED files** → apply Merge Rules:

1. Determine file type (JSON / YAML / always-overwrite / text)
2. For JSON (`.mcp.json`, `settings.json`):
   - Read both files, merge keys preserving project-only keys
   - Write merged result
3. For YAML (`.pre-commit-config.yaml`):
   - Read both files, merge entries preserving project-only hooks/repos
   - Write merged result
4. For always-overwrite files (`.claude/rules/*.md`, `.claude/agents/*.md`, `.claude/WORKFLOW.md`):
   - Copy upstream version directly
5. For other text files (skills, hooks, etc.):
   - Show diff to user, ask for `(U)pstream / (P)roject / (M)anual`
   - Default to `(P)` — preserve project version to avoid data loss

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
