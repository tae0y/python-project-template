# Proposal: Remove commit-msg enforcement hook

**Date:** 2026-02-22
**Source project:** real-estate-mcp
**Category:** rule, config
**Status:** applied

## Summary

Remove the commit-msg pre-commit hook and the Claude hook that enforce commit message prefixes. The convention applies to commits that land on "main" — feature branch and WIP commits don't need to follow it. For projects that use a PR-based open-source workflow, enforcing the convention locally on every commit is unnecessary overhead. The convention is still documented and recommended for main-branch commits, but not enforced by a hook.

## Motivation

The commit message convention is meaningful only for commits that land on "main" — feature branch commits, WIP commits, fixup commits, and squash targets don't need to follow it. When a project uses PRs for all merges, the convention is best checked at merge time (by humans or a CI lint job), not by a local pre-commit hook that fires on every single commit regardless of branch.

The downstream project (real-estate-mcp) changed `must` to `might` in the rule file, removed the Enforcement section, and dropped the `commit-msg-convention` hook from `.pre-commit-config.yaml`. The Claude hook (`check-commit-convention.sh`) is still retained for advisory feedback in Claude Code sessions, but it no longer blocks.

The rule language is relaxed to reflect that the convention is a guideline, not a hard gate. The pre-commit hook is removed entirely.

### Evidence from localdocs

No localdocs evidence — pattern is based on a direct observation in the real-estate-mcp project workflow.

| Artifact | Location | What it shows |
|----------|----------|---------------|
| — | — | — |

## Proposed Change

### Target path(s) in template

- `.claude/rules/commit-convention.md`
- `.pre-commit-config.yaml`

### Content

**`.claude/rules/commit-convention.md`** — replace with:

```markdown
# Commit Message Convention

All commit messages MUST be written in English. Every commit message on "main" branch MIGHT begin with one of the following prefixes:

- `[MAINTENANCE]` — no functional change: refactoring, formatting, dependency bumps, doc updates, test additions
- `[NEW FEATURE]` — new capability exposed to users or callers
- `[BREAKING CHANGES]` — incompatible change: removed/renamed tool, changed response schema, dropped API
```

**`.pre-commit-config.yaml`** — remove the `commit-msg-convention` hook block:

```diff
-  - repo: local
-    hooks:
-      - id: commit-msg-convention
-        name: commit message convention
-        entry: bash -c 'echo "$(<"$1")" | grep -qE "^\[(MAINTENANCE|NEW FEATURE|BREAKING CHANGES)\]" || { echo "Commit message must start with [MAINTENANCE], [NEW FEATURE], or [BREAKING CHANGES]"; exit 1; }'
-        language: system
-        stages: [commit-msg]
-        always_run: true
-        pass_filenames: false
-        args: ["--"]
-
   - repo: local
     hooks:
       - id: pyright
```

Note: If the `local` repo block only contained `commit-msg-convention`, remove the block entirely and keep only the remaining hooks.

## Caveats

- Projects that do not use a PR workflow (e.g., direct push to main) may want to keep the hook. This proposal is appropriate for open-source / PR-first workflows.
- The Claude hook (`check-commit-convention.sh`) provides advisory feedback but does not block — this is a separate decision from whether to keep the pre-commit hook.

## Review checklist

- [ ] No conflict with existing template files
- [ ] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [ ] localdocs evidence cited (or absence explicitly noted)
