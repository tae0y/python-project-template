# Workflow Guide

Components and trigger points that make up this project's workflow.
Reference when starting a new session or onboarding to `.claude/`.

---

## Overview

```
[New feature/task]        [Resume session]
        │                       │
        ▼                       ▼
   prd (optional)         /project:resume
        │                       │
        ▼                       ▼
   planning ──────────► execution loop
        │                       │
        │   worklog (auto)      │
        ▼                       ▼
  implementation ────────► commit gate
  (tdd auto-applied)      (check → auto-fix → approval)
        │
        ▼
  documentation (md-janitor, optional)
```

---

## Trigger Types

### A. Always On

Applied throughout the session without any invocation.

| Component | Condition |
|-----------|-----------|
| `python-conventions` skill | Any Python file work |
| `tdd` skill | Any code change |
| `refactoring` skill | Immediately after tests turn GREEN |

---

### B. Triggered by User Intent

Applied automatically when specific intent or keywords are detected.

| Component | Trigger conditions |
|-----------|-------------------|
| `prd` skill | "write a PRD", "document requirements", "plan a feature" |
| `planning` skill | Starting new feature/task, "how should we approach this" |
| `md-janitor` skill | "write docs", "fix README", any `.md` file editing |
| `template-upstream` skill | "reflect to template", "create a proposal" |
| `template-downstream` skill | "sync template", "pull upstream changes" |
| `template-broadcast` skill | "bulk deploy", "update all projects" |
| `template-proposal-review` skill | "review proposals", "decide upstream changes" |
| `microsoft-docs` skill | Microsoft/Azure documentation lookup needed |

---

### C. Auto-Called Within Workflow

Called automatically at specific workflow moments — no explicit invocation needed.

| Component | When | Source |
|-----------|------|--------|
| `worklog doing` | Immediately after plan approval, first step starts | `planning` skill — Worklog Automation Rule |
| `worklog done` | Immediately when step completes (tests pass) | `planning` skill — Worklog Automation Rule |
| `worklog doing` | Immediately when next step begins | `planning` skill — Worklog Automation Rule |
| `check` + `auto-fix` | Before requesting commit approval | `coding-guidelines` section 10 |
| `audit` reminder | After external library import detected | `check-external-lib-usage.sh` hook |

---

### D. Explicit Invocation Required

Must be directly requested by the user or Claude.

| Component | How to invoke | Recommended timing |
|-----------|--------------|-------------------|
| `check` skill | "run check" or auto before commit | Before commit, when issues suspected |
| `auto-fix` skill | "apply auto-fix" or auto before commit | After `check` |
| `audit` skill | "run audit" | After new dependency added; monthly |
| `/project:resume` command | Type directly | When resuming a session |
| `tdd-guardian` agent | Spawn via Task tool | When TDD compliance verification needed |
| `refactor-scan` agent | Spawn via Task tool | After GREEN, for deep refactoring assessment |
| `learn` agent | Spawn via Task tool | After feature complete, to merge knowledge |
| `adr` agent | Spawn via Task tool | When architectural decision needs recording |
| `docs-guardian` agent | Spawn via Task tool | When permanent docs need creation/improvement |
| `use-case-data-patterns` agent | Spawn via Task tool | When analyzing data patterns for new feature |

---

## Periodic Tasks

Recurring work with no automatic trigger — must be run manually.

| Task | Cadence | How |
|------|---------|-----|
| `audit` | Monthly + after each new dependency | Invoke `audit` skill |
| `.claude/` consistency audit | Quarterly or after major config changes | Enable `commands.nouse/review-team.md` and run |

After each audit run, log the result: `worklog done audit YYYY-MM-DD — [N vulnerabilities / clean]`

---

## Disabled Components

- `.claude/skills.nouse/` — see [README](.claude/skills.nouse/README.md)
- `.claude/commands.nouse/` — see [README](.claude/commands.nouse/README.md)

To enable: move the directory into `.claude/skills/` or `.claude/commands/`.
