# Follow the Plan-Implement-Document-Guard Workflow

This page describes the end-to-end development workflow used in python-template.

```
[New task]             [Resume session]
    |                       |
    ▼                       ▼
 prd (optional)     /project:resume-work
    |                       |
    v                       ▼
 planning ──────────> execution loop
    |                       |
    |   worklog (auto)      |
    ▼                       ▼
 implementation ───────> commit gate
 (tdd auto-applied)    (check -> auto-fix -> approval)
    |
    ▼
 documentation (md-janitor, optional)
```

Every task passes through four stages.

## Plan

The `planning` skill breaks work into known-good increments. Each increment must have passing tests, fit in one commit, and be describable in one sentence. If a PRD is needed, the `prd` skill runs first.

## Implement

Three skills are always active while writing code.

- `tdd` — enforces the RED-GREEN-REFACTOR cycle.
- `python-conventions` — applies PEP 8 and type hints.
- `refactoring` — assesses refactoring opportunities the moment tests turn GREEN.

Progress is recorded automatically by the `worklog` skill into `localdocs/worklog.doing.md` and `worklog.done.md`. Gotchas and patterns discovered during implementation go into `localdocs/learn.<topic>.md` immediately.

## Preserve Knowledge

When a feature is complete, content accumulated in `localdocs/learn.<topic>.md` is merged into two places.

- `learn` agent — promotes gotchas and recurring patterns into `CLAUDE.md`.
- `adr` agent — captures architectural decisions as ADRs under `localdocs/adr/`.

## Document

When documentation is needed, the `md-janitor` skill enforces consistent Markdown style.

## Guard

The Pre-Commit Quality Gate runs in sequence before every commit.

1. `check` — detects issues via ruff lint, format, pyright, and bandit (read-only).
1. `auto-fix` — applies all safe automated fixes via ruff.
1. `check` re-run — confirms the output is clean.
1. Secrets scan — verifies no API keys, tokens, or `.env` values leaked into code.

Commit approval is requested only after this gate passes.
