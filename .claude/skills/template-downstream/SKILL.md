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

**Execution model:** Claude performs read-only analysis (Steps 1–4). All file-modifying operations (Steps 5–7) are output as shell script blocks for the user to paste into their terminal. Claude never directly executes `cp`, `rm`, or file-write commands.

### 1. Resolve TEMPLATE_ROOT

Follow the priority order in Source Resolution above. Report which source was used.

### 2. Check working tree

Output this command for the user to run and confirm clean before proceeding:

```bash
git -C "$PROJECT_ROOT" status --short
```

If the user reports uncommitted changes, stop:

```
Uncommitted changes detected. Commit or stash before syncing.
```

### 3. Compute diff

Use the Read tool and `find`/`diff -q` via Bash (read-only) to compare each upstream file against the project. Classify each file as NEW, CHANGED, CHANGED (nouse), or PROJECT-ONLY.

For CHANGED files, read both versions and apply Merge Rules to determine the merged content — do not write yet.

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

N → exit.

### 5. Generate and output copy script

After confirmation, generate a single shell script block covering all updates. The user pastes it into their terminal to execute.

**Script structure:**

```bash
TEMPLATE_ROOT="<resolved-path>"
PROJECT_ROOT="<target-path>"

# NEW and always-overwrite files
mkdir -p "$PROJECT_ROOT/.claude/rules"
cp "$TEMPLATE_ROOT/.claude/rules/new-rule.md" "$PROJECT_ROOT/.claude/rules/new-rule.md"
# ... one cp line per file ...

# CHANGED (nouse) files — target skills.nouse/
cp "$TEMPLATE_ROOT/.claude/skills/tdd/SKILL.md" "$PROJECT_ROOT/.claude/skills.nouse/tdd/SKILL.md"

# .mcp.json and .pre-commit-config.yaml (if applicable)
cp "$TEMPLATE_ROOT/.mcp.json" "$PROJECT_ROOT/.mcp.json"
cp "$TEMPLATE_ROOT/.pre-commit-config.yaml" "$PROJECT_ROOT/.pre-commit-config.yaml"

echo "Done. Run: git -C \"$PROJECT_ROOT\" status --short"
```

**Rules for script generation:**

- Skip `settings.local.json` — never include it
- For CHANGED JSON/YAML files that require merging: instead of `cp`, write the merged content to a temp file and use that as the source, OR instruct the user to apply the merge manually (show the diff)
- For CHANGED text files where the user chose `(P)` — omit from script entirely
- Add `mkdir -p` before each `cp` to ensure directories exist
- One `cp` per line — no loops, no wildcards — so each line is auditable

For CHANGED files requiring manual merge, output a separate section:

```
Manual merge required for:
  .claude/skills/my-skill/SKILL.md
  → diff shown below. Edit the file manually after running the script.
  [show unified diff here]
```

### 6. Cleanup (temp clone only)

If a temp clone was created in Step 1, append to the script:

```bash
rm -rf "$TMPDIR"
```

### 7. Verify and next action

After the user runs the script, ask them to paste the output. Then output:

```bash
git -C "$PROJECT_ROOT" diff --stat
git -C "$PROJECT_ROOT" status --short
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
C) Discard all changes (git checkout -- . inside PROJECT_ROOT)
```

Wait for user choice before proceeding.
