# Proposal: Compress rules files for token efficiency

**Date:** 2026-04-05
**Source project:** TIL (20_DocHub/TIL)
**Category:** rule
**Status:** applied

## Summary

The current `coding-guidelines.md` and `document-management.md` contain redundant sections, duplicate examples, and verbose prose that inflates context tokens on every conversation. This proposal compresses both files by ~29% while preserving all rules and machine-readable structure.

## Motivation

Every CLAUDE.md and `.claude/rules/*.md` file is injected into context at conversation start. Verbose rules files consume tokens that could otherwise be used for actual work. In TIL's vault workflow — which involves 900+ notes and multiple MCP servers — reducing baseline context cost is meaningful.

Specific redundancies found:
- `coding-guidelines.md`: "Design document before implementing" and "Plan before implementing" were two separate sections saying nearly the same thing (create a plan, get approval). Merged into one.
- `coding-guidelines.md`: The Plan template code block (7 lines) added no machine-actionable value — Claude can produce this structure ad hoc.
- `document-management.md`: Table "Examples" column repeated the `localdocs/` path prefix on every row, adding no information.
- `document-management.md`: "Bootstrap" bash block duplicated as a one-liner in Rules.

### Evidence from localdocs

No localdocs evidence — pattern identified through direct token-cost analysis during a vault maintenance session.

## Proposed Change

### Target path(s) in template

- `.claude/rules/coding-guidelines.md`
- `.claude/rules/document-management.md`

### Content

#### `.claude/rules/coding-guidelines.md`

```markdown
# Coding Standards

These rules apply to all code-related tasks. They override default behavior where they conflict.

## Task size classifier

| Size | Criteria | Plan | Worklog | TDD | Examples |
|------|----------|------|---------|-----|----------|
| **TRIVIAL** | Config-only, docs-only, dependency bump, typo fix | Skip | Skip | Skip | `.md` edits, `uv lock`, `.gitignore` |
| **SMALL** | Single-file logic change, ≤ 20 lines changed | One-liner | Optional | Required | Bug fix, add validation, rename |
| **STANDARD** | Multi-file, clear scope, ≤ 1 session | Brief plan | Required | Required | New endpoint, refactor module |
| **LARGE** | Multi-session, architectural impact | Full plan + approval | Required | Required | New subsystem, migration |

When in doubt, classify one level up.

## Diagnose before fixing

IMPORTANT: Identify the root cause before proposing any solution. State the observed symptom, your root-cause hypothesis, and how you will verify it — in that order. Do not write code until the cause is understood.

## Plan before implementing

For STANDARD or LARGE tasks, create `localdocs/plan.<topic>.md` before writing any code. Minimum sections: Purpose, Stage (SPIKE/MVP/PRODUCTION), Interface, Open Questions. Wait for user approval before starting. Update and re-approve if scope changes.

For any change beyond a one-line fix, state a brief plan with verifiable checkpoints and wait for confirmation unless the user has indicated to proceed autonomously.

## Simplicity first

Write the minimum code that solves the stated problem. No speculative features, premature abstractions, or unrequested flexibility. If your solution exceeds 3x the expected size, stop and simplify.

## Surgical changes

Modify only what the current task requires. Match existing code style. Remove imports, variables, or functions that YOUR changes made unused. Do not touch pre-existing dead code or formatting unless asked. Every changed line must trace directly to the user's request.

## Verify through the real interface

Run the actual script, test file, or entry point — never simulate execution with `python -c` or inline stubs. Use the project's package manager for dependencies (`uv add`, `npm install`). Never edit lock files directly.

## Test-driven workflow

Write or update tests before implementation when the project has a test framework. Never modify existing tests to make new code pass. Never hard-code values to satisfy tests.

## Protect existing safeguards

IMPORTANT: Never remove or disable existing error handling, safety checks, linter rules, type checking, or test assertions without explicit permission. If a guard blocks your change, report the conflict — do not silently bypass it.

## Verify external dependencies

Check official documentation before using any external library or API. Use project tooling (MCP servers, context7) to verify. State when working from memory versus verified documentation.

## Direct solutions only

Take the most direct path. If you must use a workaround, name it, explain why the direct path is blocked, and get approval before proceeding.

## No silent failures

Never stub out failing paths or hard-code expected output to pass tests. If something fails and you cannot fix it, report the failure clearly.

## Context management

Commit working changes frequently for rollback safety. After extended sessions (50+ tool calls), summarize current state and remaining tasks.
```

#### `.claude/rules/document-management.md`

```markdown
# Document Management

Project documents live in `localdocs/` (gitignored, local-only) and follow strict naming conventions. The `worklog` skill and `progress-guardian` agent rely on these patterns via glob.

## File Naming Rules

| Type | Pattern | Examples |
|------|---------|---------|
| Backlog (future, pre-plan) | `backlog.*.md` | `backlog.api-v2.md` |
| Plan / architecture | `plan.*.md` | `plan.architecture.md` |
| Learning notes | `learn.*.md` | `learn.validation.md` |
| Worklog backlog | `worklog.todo.md` | fixed filename |
| Worklog in-progress | `worklog.doing.md` | fixed filename |
| Worklog completed | `worklog.done.md` | fixed filename |
| Reference material | `refer.*.md` | `refer.openapi.md` |
| ADR | `adr/adr-NNN-*.md` | `adr/adr-001-mcp-refactor.md` |

## Rules

- **Never rename** worklog files — skills depend on exact filenames.
- **Always use the prefix** when creating new documents.
- **One topic per file** — don't mix unrelated content.
- **ADR numbers are sequential.** Use kebab-case. Never reuse or skip numbers.
- `localdocs/` must be bootstrapped manually per clone: `mkdir -p localdocs/adr && touch localdocs/worklog.{todo,doing,done}.md`

## Knowledge Store Precedence

- **During work** → `localdocs/learn.*.md`
- **At feature end** → merge to `CLAUDE.md` via `learn` agent
- **Auto memory** (`~/.claude/projects/`) → cross-project patterns only
```

## Caveats

- The Plan template code block was removed from `coding-guidelines.md`. If reviewers feel it helps onboarding new users to the template, it can be restored as a collapsed example. The core rule (create a plan, get approval) is fully preserved.
- `document-management.md` Bootstrap section was collapsed into a one-liner in Rules. The `# Worklog` heading seed instruction was dropped — worklog files are typically created by the `worklog` skill anyway.

## Review checklist

- [x] No conflict with existing template files
- [x] All project-specific values removed (paths, domains, secrets)
- [ ] Downstream sync test needed after applying via template-downstream
- [x] localdocs evidence cited (or absence explicitly noted)
