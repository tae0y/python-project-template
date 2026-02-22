---
name: localdocs-til-link
description: Links a project's localdocs/ folder to the TIL repository via symlink for centralized document management. Use when setting up a new project, after accidentally deleting localdocs/, or when connecting localdocs/ to /Users/bachtaeyeong/20_DocHub/TIL for git-backed persistence. Triggered by requests like "link localdocs to TIL", "setup localdocs symlink", or "/localdocs-til-link 802 that-night-sky".
---

# localdocs-til-link

Connects a project's `localdocs/` to the TIL repo (`/Users/bachtaeyeong/20_DocHub/TIL`) via symlink. Real files live in TIL (git-managed); the project sees `localdocs/` as if it were a normal directory.

## Prerequisites

- TIL folder name is passed as an argument, e.g. `"802 that-night-sky"`
- If no argument is given, ask the user for the TIL folder name
- `TIL_BASE=/Users/bachtaeyeong/20_DocHub/TIL`
- `PROJECT_LOCALDOCS={project_root}/localdocs`

## Workflow

### 1. Check current state

```bash
ls -la {PROJECT_LOCALDOCS}
ls "{TIL_BASE}/{til_folder}"
```

- If `localdocs/` is already a symlink (`->` in `ls -la`), stop and inform the user.
- If the TIL folder doesn't exist, confirm with the user before creating it.

### 2. Merge (when both sides have files)

Copy TIL → localdocs, no overwrite:

```bash
rsync -av --ignore-existing "{TIL_BASE}/{til_folder}/" "{PROJECT_LOCALDOCS}/"
```

For files with differing timestamps, show the diff and ask the user which side is authoritative.

### 3. Move and create symlink

```bash
rm -rf "{TIL_BASE}/{til_folder}"
mv "{PROJECT_LOCALDOCS}" "{TIL_BASE}/{til_folder}"
ln -s "{TIL_BASE}/{til_folder}" "{PROJECT_LOCALDOCS}"
```

### 4. Verify

```bash
ls -la {PROJECT_LOCALDOCS}         # confirm symlink (look for ->)
ls "{TIL_BASE}/{til_folder}/"      # confirm files are present
```

## Notes

- `localdocs/` must be in the project's `.gitignore`. If missing, recommend adding it.
- Always quote paths containing spaces.
- After setup, remind the user to commit in the TIL repo.
