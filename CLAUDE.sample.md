# [Project Name] — Claude Code Guide

Brief description of this project and its purpose.

---

## Reading Order for New Sessions

When starting a session in this project, read in this order:
1. `CLAUDE.md` (this file) — project overview and communication style
2. `.claude/WORKFLOW.md` — trigger map: what runs when, and how
3. `.claude/rules/` — behavioral constraints applied to every response
4. `.claude/skills/` — domain-specific patterns loaded as background context
5. `localdocs/worklog.doing.md` — active task state (if resuming work)

---

## Project Context

<!-- Describe the domain, key constraints, and any context a new session needs to be effective immediately. -->

---

### Rule Hierarchy

When rules from different files apply to the same response, use this priority order:

- Non-code responses: `thinking-guidelines` > `CLAUDE.md`
- Code tasks: `coding-guidelines` > `CLAUDE.md`
- When rules conflict: prefer thinking (surface trade-offs, ask) over acting (proceed and fix later)
