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

The `planning` skill structures the work before any code is written. It begins with a sequence of steps designed to make sure both the programmer and the AI have a shared, accurate understanding of what needs to be built and why.

**What these steps do:**

1. **Declare the work stage** — Is this exploratory (SPIKE), a first working version (MVP), or production-ready code (PROD)? This shapes how much rigor to apply throughout.
2. **Check technical feasibility** — Before committing to an approach, the AI searches for known issues, version differences, and API behaviors that training data may have missed.
3. **Specify requirements in writing (BDD step)** — For MVP and PROD work, the programmer writes down what success looks like *before* implementation starts. This means two things:
   - A short user-story document (`localdocs/user-story.*.md`) describing who needs what and why, written by the programmer in plain language.
   - Failing test cases (`tests/test_*.py`) that describe the expected behavior using Given/When/Then structure, also written by the programmer.
   
   The AI does not write these. Writing them forces the programmer to understand the requirements well enough to express them as tests — catching ambiguity before it becomes bugs. The AI asks clarifying questions until understanding is shared, then waits.
   
   For exploratory SPIKE work, only the clarifying questions are required; no written artifacts.
4. **Interview for implementation unknowns** — Even with requirements clear, there are usually open questions about *how* to build: data shapes, error handling, edge cases. The AI asks these before creating a plan.

After these steps, a plan file (`localdocs/plan.<topic>.md`) is created and approved by the programmer. Each step in the plan maps to one commit, has a clear done condition, and starts with a failing test.

If a product requirements document is needed before planning, the `prd` skill runs first.

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
