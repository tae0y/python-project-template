# Proposal: Remove hardcoded local paths from template skills

**Date:** 2026-02-22
**Source project:** real-estate-mcp
**Category:** skill
**Status:** applied

## Summary

Three skill files in the template contain hardcoded absolute paths tied to a specific user's machine. When downstream projects share these skills in a public repository (e.g., GitHub with 100+ stars), those paths appear in committed code and break immediately for any other user. This proposal replaces all hardcoded paths with user-prompt fallbacks so skills work on any machine without modification.

## Motivation

The issue was discovered during a pre-commit review of `.claude/` before pushing to a public repo. Files synced from upstream via `template-downstream` contained paths like `/Users/<username>/...` that were committed verbatim into a project with 100+ GitHub stars.

Three skills are affected:

| Skill file | Hardcoded value | Impact |
|------------|----------------|--------|
| `skills.nouse/localdocs-til-link/SKILL.md` | `TIL_BASE=/Users/<username>/20_DocHub/TIL` | Core functionality silently fails on any other machine |
| `skills/template-downstream/SKILL.md` | Local path check for python-template clone | Always falls through to network clone; misleads users |
| `skills/template-proposal-review/SKILL.md` | Local path check for python-template clone | Same as above |

For `localdocs-til-link`, the hardcoded value is load-bearing: the bash commands in the workflow all expand `{TIL_BASE}` from that constant. On another machine, the commands point to a non-existent path and fail silently.

For the two template skills, the hardcoded path is a "fast path" optimisation. It still degrades gracefully (falls through to clone), but it creates confusion and the path is committed into downstream repos unnecessarily.

### Evidence from localdocs

No localdocs evidence — pattern is theoretical, but the root cause (hardcoded path in a shared file committed to a public repo) was directly observed during this session.

## Proposed Change

### Target path(s) in template

- `.claude/skills.nouse/localdocs-til-link/SKILL.md`
- `.claude/skills/template-downstream/SKILL.md`
- `.claude/skills/template-proposal-review/SKILL.md`

### Content

**`.claude/skills.nouse/localdocs-til-link/SKILL.md` — Prerequisites section (replace)**

```markdown
## Prerequisites

Ask the user for the following if not provided as arguments:

- **TIL folder name** — the subdirectory inside TIL for this project, e.g. `"802 that-night-sky"`
- **TIL_BASE** — absolute path to the TIL repository root, e.g. `~/20_DocHub/TIL`

Resolve `TIL_BASE` to an absolute path before use (expand `~` if needed).

- `PROJECT_LOCALDOCS={project_root}/localdocs`
```

**`.claude/skills/template-downstream/SKILL.md` — Source Resolution step 1 (replace)**

```markdown
1. **User-provided path** — ask the user: "Do you have a local clone of the template repo? If yes, provide the path." If provided and `<path>/.claude/` exists, use it as `TEMPLATE_ROOT`. No network required.
```

**`.claude/skills/template-proposal-review/SKILL.md` — Prerequisites line (replace)**

```markdown
- Local template path (if available): ask the user — "Do you have a local clone of the template repo? If yes, provide the path."
```

**`.claude/skills/template-proposal-review/SKILL.md` — Apply step 1 (replace)**

```markdown
1. **User-provided path** — if the user provided a local path above and it exists, use it directly. No clone needed.
```

## Caveats

- `localdocs-til-link` is in `skills.nouse/` so it is not loaded by default, but it is still committed and visible in public repos.
- The fix for `template-downstream` removes the local fast-path optimisation for users who have the template cloned. This is acceptable: they will be prompted to provide the path, which is a one-time UX cost in exchange for correctness.
- If the template maintainer wants to preserve the fast-path, an alternative is to read the path from an environment variable (e.g., `PYTHON_TEMPLATE_ROOT`) rather than hardcoding it.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
